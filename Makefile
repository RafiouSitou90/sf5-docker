DC=docker-compose
DE=docker exec
COMPOSER=COMPOSER_MEMORY_LIMIT=-1 composer
SYMFONY_CONSOLE=php bin/console
DOCKER_RUN_TEST=$(DOCKER_COMPOSE) -f docker-compose.test.yml run --rm

## —— Docker for dev environment ——————————————————————————————————————————————————
up: ## Start docker for dev server
	$(DC) up -d

## —— Docker for prod environment ——————————————————————————————————————————————————
up-prod:
	$(DC) -f docker-compose.prod.yml up -d --build

stop:
	$(DC) stop

down:
	$(DC) down

rebuild:
	$(DC) down -v --remove-orphans
	$(DC) rm -vsf
	$(DC) up -d --build

## —— vendor ———————————————————————————————————————————————————————————————
vendor-install: ## Install vendor all packages
	$(COMPOSER) install

vendor-update: ## Update vendor all packages
	$(COMPOSER) update

clean-vendor: ## Delete vendor folder and reinstall it
	rm -Rf vendor
	rm composer.lock
	$(COMPOSER) install

## —— cache ———————————————————————————————————————————————————————————————
cache: ## Clear the cache
	$(SYMFONY_CONSOLE) cache:clear
	$(SYMFONY_CONSOLE) cache:warmup

cache-test: ## Clear the tests environment cache
	$(SYMFONY_CONSOLE) cache:clear --env=test
	$(SYMFONY_CONSOLE) cache:warmup --env=test

cache-hard: ## Delete the cache folder sub-folder
	rm -fR var/cache/*

## —— fixtures ———————————————————————————————————————————————————————————————
fixtures: ## Load fixtures
	make clean-db
	$(SYMFONY_CONSOLE) doctrine:fixtures:load --no-interaction

## —— database ———————————————————————————————————————————————————————————————
clean-db: ## Reset the database
	$(SYMFONY_CONSOLE) doctrine:database:drop --if-exists --force
	$(SYMFONY_CONSOLE) doctrine:database:create
	$(SYMFONY_CONSOLE) doctrine:migrations:migrate --no-interaction

clean-db-test: cache-hard cache-test ## Reset the database of the tests environment
	$(SYMFONY_CONSOLE) doctrine:database:drop --if-exists --force --env=test
	$(SYMFONY_CONSOLE) doctrine:database:create --env=test
	$(SYMFONY_CONSOLE) doctrine:migrations:migrate --no-interaction --env=test
