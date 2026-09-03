# Changelog

## [2026-09-03]

### Changed
- **Build movido a GitHub Actions**: se elimina el trigger de Cloud Build `odoo-activator` y `.gcp/cloudbuild.yaml`. Ese trigger pusheaba a `us-east4-docker.pkg.dev/.../cloud-run-source-deploy/odoo-docker/odoo-17.0`, un path que ningún Dockerfile consumía realmente (fallaba además por falta de permiso `secretmanager.versions.access`). El nuevo workflow `.github/workflows/build_push.yml` construye y pushea `17.0/Dockerfile` a `us-central1-docker.pkg.dev/fop-comunidad/fop/odoo/odoo-17.0` (el path real que consume `fop-odoo-enterprise/Dockerfile`) en cada push a `master` que toque `17.0/**`, autenticando con el mismo secret `GCP_SA_KEY` que ya usa `fop-odoo`. `MAXMIND_ACCOUNT_ID`/`MAXMIND_LICENSE_KEY` pasan a ser secrets de GitHub Actions en este repo en vez de Secret Manager de GCP.

## [2026-06-08]

### Added
- **GeoIP support**: `17.0/Dockerfile` descarga `GeoLite2-Country.mmdb` y `GeoLite2-City.mmdb` de MaxMind durante el build cuando se proveen los build args `MAXMIND_ACCOUNT_ID` y `MAXMIND_LICENSE_KEY`. Los archivos quedan en `/usr/share/GeoIP/`. El paso es opcional: si no se pasan los args, el build continúa sin los archivos.
- **Cloud Build secrets**: `.gcp/cloudbuild.yaml` expone `MAXMIND_ACCOUNT_ID` y `MAXMIND_LICENSE_KEY` desde Google Cloud Secret Manager como `secretEnv` y los pasa como `--build-arg` al docker build.
