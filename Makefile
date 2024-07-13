# Makefile

SHELL = /bin/bash

ifndef VERBOSE
MAKEFLAGS += --no-print-directory
endif

include $(PWD)/.env.example
-include $(PWD)/.env

help:
	@printf '		'
	@make print-color-blue TEXT='** Available commands **\n\n'
	@make print-color-green TEXT='install-backend'
	@printf '		install backend dependencies\n'

install-backend: init-env up-backend
	@make composer-install
	@make docker-exec CONTAINER="php" CONTAINER_CMD="sh -c 'php artisan storage:link --force'"
	@make up-db

composer-install:
	@make docker-exec CONTAINER="php" CONTAINER_CMD="composer install -n"

init-env:
	@test -f .env || cp .env.example .env

up-db:
	@make docker-exec CONTAINER="php" CONTAINER_CMD="php artisan migrate"

up-backend:
	@make docker-compose-exec COMPOSE_CMD="up -d web"

docker-exec:
	@docker exec -it $(APP_NAME)-$(CONTAINER) $(CONTAINER_CMD)

docker-compose-exec:
	@docker compose $(COMPOSE_CMD)

print-color-green:
	@printf '\033[0;32m${TEXT}\033[0m'

print-color-blue:
	@printf '\033[0;36m${TEXT}\033[0m'
