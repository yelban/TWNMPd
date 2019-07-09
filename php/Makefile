-include .env



APP = $(APP_NAME)
TAG = $(APP_VERSION)
REPO = $(PROJECT_NAME)/$(APP)
NAME = $(PROJECT_NAME)-$(APP)-$(TAG)
PORTS = -p $(HOST_PORT):$(EXPOSE_PORT)
VOLUMES = -v $(PV_BASE):$(APP_ROOT):cached

ENV = -e APP_ROOT=$(APP_ROOT) \
	-e WITH_DRUPAL=$(WITH_DRUPAL) \
	-e WITH_DRUPAL_COMPOSER=$(WITH_DRUPAL_COMPOSER) \
	-e DRUPAL_VERSION=$(DRUPAL_VERSION) \
	-e PROJECT_BASE_URL=$(PROJECT_BASE_URL) \
	-e PM_MAX_CHILDREN=$(PM_MAX_CHILDREN) \
	-e PHP_MEMORY_LIMIT=$(PHP_MEMORY_LIMIT) \
	-e PHP_MAX_EXECUTION_TIME=$(PHP_MAX_EXECUTION_TIME) \
	-e PHP_UPLOAD_MAX_FILESIZE=$(PHP_UPLOAD_MAX_FILESIZE) \
	-e PHP_POST_MAX_SIZE=$(PHP_POST_MAX_SIZE) \
	-e PHP_MAX_FILE_UPLOADS=$(PHP_MAX_FILE_UPLOADS) \
	-e TIMEZONE=$(TIMEZONE) \
	\
	-e MYSQL_DATABASE=$(MYSQL_DATABASE) \
	-e MYSQL_USER=$(MYSQL_USER) \
	-e MYSQL_PASSWORD=$(MYSQL_PASSWORD) \
	-e MYSQL_PREFIX=$(MYSQL_PREFIX) \
	-e MYSQL_HOST=$(MYSQL_HOST) \
	-e MYSQL_PORT=$(MYSQL_PORT) \
	\
	-e RELAY_HOST=$(RELAY_HOST) \
	-e RELAY_PORT=$(RELAY_PORT) \
	-e RELAY_USER=$(RELAY_USER) \
	-e RELAY_FROM=$(RELAY_FROM) \
	-e RELAY_SECRETS=$(RELAY_SECRETS) \
	\
	-e WITH_MAILHOG=$(WITH_MAILHOG) \
	-e MAILHOG_HOST=$(MAILHOG_HOST) \
	-e MAILHOG_PORT=$(MAILHOG_PORT)

ARG = --log-driver=syslog \
	--log-opt syslog-address="udp://$(HOST_IP):$(RSYSLOG_PORT)" \
	--log-opt syslog-format=rfc3164 \
	--log-opt tag=php

.PHONY: build push shell sh run up down stop clean prune log logs release

default: build

build:
	docker build -t $(REPO):$(TAG) \
	--build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
	--build-arg TIMEZONE=$(TIMEZONE) \
	./

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/sh

sh:
	docker exec -it $(NAME) /bin/sh

run:
	docker run --rm --name $(NAME) $(LINKS) $(PORTS) $(VOLUMES) $(ENV) $(ARG) $(REPO):$(TAG) $(CMD)

up:
	docker run --rm -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(ARG) $(REPO):$(TAG)

down:
	docker stop $(NAME)

stop:
	docker stop $$(docker ps -aq)

clean:
	-docker rm -f $(NAME)

prune:
	docker system prune -a -f

log:
	docker logs $(NAME)

logs:
	docker logs -f $(NAME)

release: build push
