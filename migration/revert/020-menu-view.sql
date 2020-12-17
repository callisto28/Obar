-- Revert migrations:020-menu-view from pg

BEGIN;

DROP VIEW menu;

COMMIT;
