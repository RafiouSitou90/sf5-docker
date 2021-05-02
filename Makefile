DC=docker-compose
DE=docker exec

up:
	$(DC) up -d

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

container-php:
	$(DE) -it container_sf5_php bash
