.DEFAULT_GOAL := all
IMAGE=example/app:latest
ENV=$(shell grep "APP_ENV" .env | cut -d '=' -f2 | sed -e 's/^"//' -e 's/"$$//')
PWD=$(shell pwd)

PHPDC=./.docker/docker-compose exec -u www-data php php

PHP=docker run --rm -it \
	-v $(PWD):/var/www/html \
	--user www-data:www-data \
	$(IMAGE)

COMPOSER=docker run --rm -it \
	-v $(HOME)/.cache/docker-composer:/var/www/.composer \
	-v $(PWD):/var/www/html \
	--user www-data:www-data \
	$(IMAGE) composer

NODE=docker run --rm -it \
	-v $(HOME)/.cache/docker-yarn-cache:/usr/local/share/.cache/yarn/v1 \
	-v $(PWD):/app \
	--user node:node \
	-w /app node:lts

all: setup install reset migrate

setup:
	cd .docker; \
		export APP_ENV=$(ENV) && \
		./docker-compose build && ./docker-compose up -d

install:
	$(COMPOSER) install --prefer-dist --no-interaction --no-suggest --no-ansi
	$(NODE) yarn install --frozen-lockfile
	$(NODE) yarn

migrate:
	$(PHPDC) artisan migrate

test:
	$(PHP) ./vendor/bin/phpunit

php:
	$(PHP) /bin/bash

reset:
	$(PHP) php artisan view:clear
	$(PHP) php artisan config:clear
	$(PHP) php artisan cache:clear
	$(PHP) php artisan clear-compiled
	$(PHP) rm -rf storage/framework/sessions/*
	$(PHP) rm -rf storage/framework/cache/data/*

reset-db:
	cd .docker; \
		./docker-compose down && \
		docker volume rm app_database && \
		./docker-compose up -d


