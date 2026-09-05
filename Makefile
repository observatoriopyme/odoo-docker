.PHONY: build push check_vars update-odoo-src

PROJECT_ID=fop-comunidad
REGION=us-central1
REPOSITORY=fop
ODOO_VERSION=17.0
ASSET=odoo

DOCKER_IMAGE_BASE=${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${ASSET}/odoo-${ODOO_VERSION}
IMAGE_VERSION := $(shell git rev-parse --short HEAD)
DOCKER_IMAGE=${DOCKER_IMAGE_BASE}:${IMAGE_VERSION}
DOCKER_IMAGE_LATEST=${DOCKER_IMAGE_BASE}:latest

# odoo/ es solo una copia del fuente para navegar/debuggear (path mapping del
# debugger de VSCode), nunca se monta ni se ejecuta -- por eso update-odoo-src
# no clona el repo de Odoo, descarga el tar.gz nightly que corresponde al
# ODOO_VERSION/ODOO_RELEASE del Dockerfile de esta version.
ODOO_DOCKERFILE=${ODOO_VERSION}/Dockerfile
ODOO_SRC_DIR := $(abspath ../odoo)
ODOO_NIGHTLY_VERSION := $(shell sed -n 's/^ENV ODOO_VERSION=//p' ${ODOO_DOCKERFILE})
ODOO_NIGHTLY_RELEASE := $(shell sed -n 's/^ARG ODOO_RELEASE=//p' ${ODOO_DOCKERFILE})

check_vars:
	@echo Region: ${REGION}
	@echo Odoo Version: ${ODOO_VERSION}
	@echo Image Version: ${IMAGE_VERSION}
	@echo Docker Image: ${DOCKER_IMAGE}
	@echo Docker Image Latest: ${DOCKER_IMAGE_LATEST}

build: check_vars
	docker build -f ${ODOO_VERSION}/Dockerfile ${ODOO_VERSION}/ \
		-t ${DOCKER_IMAGE} \
		-t ${DOCKER_IMAGE_LATEST}
	@echo "${IMAGE_VERSION}" > .image_version

push:
	@VERSION=$$(cat .image_version) && \
	docker push "${DOCKER_IMAGE_BASE}:$$VERSION" && \
	docker push "${DOCKER_IMAGE_LATEST}"

# Reemplaza el contenido de ../odoo por el tar.gz nightly de ODOO_VERSION/ODOO_RELEASE
# (leidos de ${ODOO_DOCKERFILE}), la misma version que instala el Dockerfile via .deb.
update-odoo-src:
	@test -n "${ODOO_NIGHTLY_VERSION}" || (echo "No pude leer ENV ODOO_VERSION de ${ODOO_DOCKERFILE}" && exit 1)
	@test -n "${ODOO_NIGHTLY_RELEASE}" || (echo "No pude leer ARG ODOO_RELEASE de ${ODOO_DOCKERFILE}" && exit 1)
	@echo "Descargando fuente de Odoo ${ODOO_NIGHTLY_VERSION}.${ODOO_NIGHTLY_RELEASE} hacia ${ODOO_SRC_DIR}"
	rm -rf .odoo_src_tmp
	mkdir -p .odoo_src_tmp
	curl -sSL --fail -o .odoo_src_tmp/odoo.tar.gz \
		"http://nightly.odoo.com/${ODOO_NIGHTLY_VERSION}/nightly/tgz/odoo_${ODOO_NIGHTLY_VERSION}.${ODOO_NIGHTLY_RELEASE}.tar.gz"
	tar -xzf .odoo_src_tmp/odoo.tar.gz -C .odoo_src_tmp
	mkdir -p "${ODOO_SRC_DIR}"
	find "${ODOO_SRC_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
	bash -c 'mv .odoo_src_tmp/odoo-*/* "${ODOO_SRC_DIR}"/'
	rm -rf .odoo_src_tmp
	@echo "odoo/ actualizado a ${ODOO_NIGHTLY_VERSION}.${ODOO_NIGHTLY_RELEASE}"

.DEFAULT_GOAL := check_vars
