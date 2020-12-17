-- Revert migrations:030-ingredient_bought from pg

BEGIN;

DROP FUNCTION ingredient_bought;

COMMIT;
