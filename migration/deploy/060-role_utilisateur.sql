-- Deploy migrations:060-role_utilisateur to pg

BEGIN;

-- Usuellement on évitera de créer les mots de passes
-- des role utilisateur dans les migrations
-- pour ne pas laisser de trace écrite
-- Il faudra se connecter avec psql à un compte admin pour les définir
CREATE ROLE obar_web WITH LOGIN;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO obar_web;

REVOKE DELETE ON drink FROM obar_web;
REVOKE INSERT ON stock FROM obar_web;

COMMIT;
