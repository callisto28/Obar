-- Deploy migrations:050-stock_vente_solde_restock_classement to pg

BEGIN;

--CREATE VIEW STOCK
-- je viens creer ma view pour le stock initail
CREATE VIEW stock_initial AS
-- je selectionne les champs que j'ai besoin 
SELECT ingredient.name, ingredient.id ,SUM(quantity) AS stock_base
--sur la table ingredient
FROM ingredient
-- j'ajoute les tables suplementaires
JOIN stock
-- sur 
ON stock.ingredient_id = ingredient.id
-- et vu que je fais une SUM ej dois creer un groupe by
GROUP BY  stock.ingredient_id, ingredient.name,ingredient.id
-- ici j'ajoute un ordre a cette base nouvelement creé
ORDER BY stock_base DESC;


CREATE VIEW stock_bu AS
SELECT m_ingre.ingredient_id, SUM(m_ingre.quantity) AS stock_in
FROM history
JOIN _m2m_drink_ingredient m_ingre
ON m_ingre.drink_id = history.drink_id
GROUP BY history.drink_id, m_ingre.ingredient_id;


CREATE VIEW stock_final AS
SELECT ingredient.name, stock_initial.stock_base, stock_bu.stock_in,
(stock_initial.stock_base - stock_bu.stock_in) AS solde
FROM ingredient
JOIN stock_initial
ON stock_initial.id = ingredient.id
JOIN stock_bu
ON stock_bu.ingredient_id = ingredient.id;

--CREATE FUNCTION VENTE

CREATE FUNCTION sale (drink_id INT) RETURNS NUMERIC AS
$$
    INSERT INTO history(drink_id) VALUES (drink_id);
    SELECT price FROM drink WHERE drink_id =drink.id;
$$
LANGUAGE sql VOLATILE STRICT;

--CREATE VIEW SOLDE

CREATE VIEW list_of_buy AS
SELECT  history.drink_id, SUM(drink.price), DATE(history.sell_date) AS sum_total
FROM history
JOIN drink
ON drink.id= history.drink_id
GROUP BY history.drink_id, history.sell_date;

--CREATE FUNCTION REASSORT

CREATE FUNCTION new_stock ( N INT) RETURNS SETOF stock_final AS
$$   
    SELECT * FROM stock_final ORDER BY stock_base LIMIT N;
$$
LANGUAGE sql VOLATILE STRICT;



CREATE VIEW preference AS

SELECT drink.name, COUNT(drink_id) AS number_of_sales 
FROM history 
RIGHT OUTER JOIN drink
ON history.drink_id = drink.id
GROUP BY history.drink_id, drink.name
ORDER BY number_of_sales DESC;




COMMIT;
