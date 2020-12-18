# Le type de données JSON

Postgres dispose d'un type de données JSON extremement pratique.

Il permet de stocker des données structurées dans une colonne et de librement accéder (ou filter) par ces données.

ex:

```sql
CREATE TABLE config_cockpit (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    config JSON
);

INSERT INTO config_cockpit(config)
     VALUES ('{"mode": "dark", "screen_size": { "width": 400, "height": 300}}'::JSON); -- ici je "cast" ma string en type JSON

-- JE récupère tt l'objet JSON
SELECT config FROM config_cockpit;

-- Avec -> je viens lire la propriété qui à pour clé 'mode'
-- Attention le résultat est de type JSON je ne peux donc pas
-- le comparer directement à une string par ex
SELECT config->'mode' FROM config_cockpit;

-- Pour avoir un résulat en type TEXT je dois doubler la pointe
SELECT config->>'mode' FROM config_cockpit;

-- Je peux parcourir les objets (le parcour se fait avec -> et je met ->> pour
-- la dernière valeur)
SELECT config->'screen_size'->>'width' FROM config_cockpit;

-- Je peux utiliser ceci partout dans ma requête :
SELECT config->'screen_size'->>'width'
  FROM config_cockpit
 WHERE config->>'mode' = 'dark';
```

## Les paramètres des fonctions

Pour l'instant c'est compliqué d'avoir des fonctions avec de nombreux params.

On pourrait utiliser les "types complexes" de Pg (pg créé un type custom réprentant les données de chaque table) mais il y deux inconvénients majeurs :

1. Je suis obligé de données une valeur pour toutes les colonnes NOT NULL et de données les valeurs dans l'ordre
2. Nos fonctions seront surement appelé depuis de JS et notre module `pg` ne sais pas se servir des types complexes

On peut utiliser le type JSON pour palier à ça.

La structure du JSON est libre et le module `pg` converti automatiquement les objets JS en JSON pour Postgres.

## Réciproque

Lorsque le module `pg` recoit des données au type JSON il convertit automatiquement pour le JS.

Sans ça

```sql
SELECT post.*,
       category.label AS category_label,
       category.route AS category_route
  FROM post
  JOIN category
    ON post.category_id = category.id;
```

```javascript
// on accèderais aux données coome ça
const result = await client.query('..');
for (let post of resut.rows) {
    console.log(post.category_label, post.category_route)
}
```

Ca fait le taf mais peut faire mieux

```sql
SELECT post.*,
       to_json(category) AS category
  FROM post
  JOIN category
    ON post.category_id = category.id;

-- Toutes les colonnes de l'objet category vont être mise dans un JSON
```

```javascript
// le module pg converti la colonne category en objet directement
const result = await client.query('..');
for (let post of resut.rows) {
    console.log(post.category.label, post.category.route)
}
```

Encore mieux :

```sql
SELECT category.*,
       JSON_AGG(post)
  FROM category
  JOIN post
    ON post.category_id = category.id
GROUP BY category.id, category.label, category.route
```

```javascript
const result = await client.query('..');
for (let category of resut.rows) {
    for (let post of category.post) {
        console.log(post.title);
    }
}
```
