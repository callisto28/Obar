-- Revert migrations:040-drink-soft-delete from pg

BEGIN;

DROP FUNCTION delete_drink;

CREATE OR REPLACE VIEW menu AS
SELECT drink.id,
       drink.name,
       drink.price,
       ARRAY_AGG(q.quantity || ' ' || ingredient.name) AS recipe
  FROM drink
  JOIN _m2m_drink_ingredient q
    ON drink.id = q.drink_id
  JOIN ingredient
    ON ingredient.id = q.ingredient_id
GROUP BY drink.id, drink.name, drink.price;

ALTER TABLE drink
       DROP deleted;

COMMIT;
