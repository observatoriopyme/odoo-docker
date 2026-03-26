.PHONY: build push check_vars

PROJECT_ID=fop-comunidad
REGION=us-east4
REPOSITORY=deploy
ODOO_VERSION=17.0

DOCKER_IMAGE_BASE=${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/fop-odoo/odoo-${ODOO_VERSION}
IMAGE_VERSION=$(shell git rev-parse --short HEAD)
DOCKER_IMAGE=${DOCKER_IMAGE_BASE}:${IMAGE_VERSION}
DOCKER_IMAGE_LATEST=${DOCKER_IMAGE_BASE}:latest

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

push: build
	docker push "${DOCKER_IMAGE}"
	docker push "${DOCKER_IMAGE_LATEST}"

.DEFAULT_GOAL := check_vars
