-- Deploy migrations:030-ingredient_bought to pg

BEGIN;
-- Cette fonction ne renverra rien (elle fait juste un insert)
-- sont type de retour est  donc VOID
-- pour securise on utilisera CALLED ON NULL INPUT + VOLATILE
-- sur le back JS du coup je peux appeler ma fonction en faisant SELECT ingredient_bought

CREATE FUNCTION ingredient_bought(ingredient_id INT, quantity INT) RETURNS VOID AS
$$
    INSERT INTO stock(ingredient_id, quantity) VALUES (ingredient_id, quantity);
$$
LANGUAGE sql VOLATILE STRICT;
COMMIT;
