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

install-backend: init-env up-backend sync-db
	@make composer-install
	@make docker-exec CONTAINER="php" CONTAINER_CMD="sh -c 'php artisan storage:link --force'"

init-env:
	@test -f .env || cp .env.example .env

up-backend:
	@make docker-compose-exec COMPOSE_CMD="up -d web db"

composer-install:
	@make docker-exec CONTAINER="php" CONTAINER_CMD="composer install -n"

sync-db:
	@printf '=== Waiting for DB server'
	@while [ -z "$$(docker compose logs db 2>&1 | grep -o 'Server socket created')" ]; \
		do printf '.'; \
		sleep 2; \
		done;
	@printf '\n=== Import data from ${DB_SRC_HOST} to ${DB_HOST} ... '
	@make docker-exec \
		CONTAINER="db" \
		CONTAINER_CMD="sh -c 'mysqldump -qQR --add-drop-table --skip-lock-tables --skip-comments --ssl -h${DB_SRC_HOST} -u${DB_USERNAME} -p${DB_PASSWORD} ${DB_DATABASE} | mysql -u${DB_USERNAME} -p${DB_PASSWORD} ${DB_DATABASE}'"
	@make print-color-green TEXT='DONE\n'

docker-exec:
	@docker exec -it $(APP_NAME)-$(CONTAINER) $(CONTAINER_CMD)

docker-compose-exec:
	@docker compose $(COMPOSE_CMD)

print-color-green:
	@printf '\033[0;32m${TEXT}\033[0m'

print-color-blue:
	@printf '\033[0;36m${TEXT}\033[0m'
