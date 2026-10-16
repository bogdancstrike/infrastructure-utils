# Hera Keycloak development example

Uses the current upstream Keycloak image with `start-dev`, persistent development data and the local theme directory. Select a realm theme through Keycloak administration; the old `KC_THEME_DEFAULT` variable did not select themes.

Override `KEYCLOAK_ADMIN` and `KEYCLOAK_ADMIN_PASSWORD` in `.env`; Compose maps them to the current `KC_BOOTSTRAP_ADMIN_*` variables. These initialize a new administrator and do not reset an existing account. Validate with `docker compose config --quiet` before starting when wanted.

For realm transfers, use Keycloak's documented export/import commands with the same supported server version. Exporting a container filesystem does not include named volume data. Back up the actual database or development data volume before changing versions.
