-- Runs once, only on a fresh postgres_data volume (docker-entrypoint-initdb.d).
-- Executed as $POSTGRES_USER against $POSTGRES_DB, so each schema is owned by
-- the same role the apps connect with (KC via KC_DB_USERNAME, bff via DB_URI).
--
-- Each app owns its tables/migrations inside its schema (Keycloak's bundled
-- Liquibase for `kc`, Drizzle for `bff`) — but neither tool creates the
-- schema itself, so we provision both up front.
CREATE SCHEMA IF NOT EXISTS kc;
CREATE SCHEMA IF NOT EXISTS bff;
