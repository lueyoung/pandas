include Makefile.inc
DATE:=$(shell date)
DOCKER=$(shell which docker)

define sed
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"$(1)"?"$(2)"?g
endef
define sed0
	@find ${MANIFEST} -type f -name "Dockerfile" | xargs sed -i s?"$(1)"?"$(2)"?g
endef

restart: rm mk mv docker
docker: build run
all: build push deploy

.PHONY: build push restart docker all rm run clean stop enter test pull

build:
	@docker $@ -t ${IMAGE} -f Dockerfile .

push:
	@docker $@ ${IMAGE}

pull:
	@docker $@ ${IMAGE}

run:
	${DOCKER} $@ -d -v $(shell pwd)/workspace:/mnt --name ${NAME} --restart=on-failure:5 ${IMAGE} tail -f /dev/null

clean: stop rm
rm: 
	-${DOCKER} $@ ${NAME}

stop:
	-${DOCKER} $@ ${NAME}

enter:
	docker exec -it ${NAME} /bin/bash

