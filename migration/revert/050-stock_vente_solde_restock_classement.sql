-- Revert migrations:050-stock_vente_solde_restock_classement from pg

BEGIN;

DROP VIEW preference;

DROP FUNCTION new_stock;

DROP VIEW list_of_buy;

DROP FUNCTION sale;

DROP VIEW stock_final;

DROP VIEW stock_bu;

DROP VIEW stock_initial;

COMMIT;
