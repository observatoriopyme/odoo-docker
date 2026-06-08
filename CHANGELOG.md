# Changelog

## [2026-06-08]

### Added
- **GeoIP support**: `17.0/Dockerfile` descarga `GeoLite2-Country.mmdb` y `GeoLite2-City.mmdb` de MaxMind durante el build cuando se proveen los build args `MAXMIND_ACCOUNT_ID` y `MAXMIND_LICENSE_KEY`. Los archivos quedan en `/usr/share/GeoIP/`. El paso es opcional: si no se pasan los args, el build continúa sin los archivos.
- **Cloud Build secrets**: `.gcp/cloudbuild.yaml` expone `MAXMIND_ACCOUNT_ID` y `MAXMIND_LICENSE_KEY` desde Google Cloud Secret Manager como `secretEnv` y los pasa como `--build-arg` al docker build.
