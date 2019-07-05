-include .env



APP = $(APP_NAME)
TAG = $(APP_VERSION)
REPO = $(PROJECT_NAME)/$(APP)
NAME = $(PROJECT_NAME)-$(APP)-$(TAG)
PORTS = -p $(HOST_PORT):$(EXPOSE_PORT)
VOLUMES = -v $(PV_CODEBASE):cached

ENV = -e MYSQL_DATABASE=$(MYSQL_DATABASE) \
	-e MYSQL_USER=$(MYSQL_USER) \
	-e MYSQL_PASSWORD=$(MYSQL_PASSWORD) \
	-e MYSQL_ROOT_PASSWORD=$(MYSQL_ROOT_PASSWORD)

ARG = --log-driver=syslog \
	--log-opt syslog-address="udp://$(HOST_IP):$(RSYSLOG_PORT)" \
	--log-opt syslog-format=rfc3164 \
	--log-opt tag=db

CMD = --character-set-server=utf8mb4 \
	--collation-server=utf8mb4_unicode_ci


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
	docker run --rm -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(ARG) $(REPO):$(TAG) $(CMD)

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
