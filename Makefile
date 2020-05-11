include Makefile.inc
DATE:=$(shell date)

define sed
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"$(1)"?"$(2)"?g
endef
define sed0
	@find ${MANIFEST} -type f -name "Dockerfile" | xargs sed -i s?"$(1)"?"$(2)"?g
endef

restart: rm mk mv docker
docker: build run
all: build push deploy

.PHONY : compile
compile:
	@cd ${COMPILE} && BIN_CM=${NAME}-bin NAMESPACE=${NAMESPACE} make 

.PHONY: clearn-compile
clean-compile:
	@cd ${COMPILE} && BIN_CM=${NAME}-bin NAMESPACE=${NAMESPACE} make clean 

.PHONY: build
build:
	@docker $@ -t ${IMAGE} -f Dockerfile .

.PHONY: push
push:
	@docker $@ ${IMAGE}

.PHONY: mk
mk: cp
mk:
	$(call sed0, {{.verbose}}, $(DATE))

.PHONY: mv
mv:
	@yes | cp ${MANIFEST}/Dockerfile ./

.PHONY: cp 
cp:
	@find ${MANIFEST} -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

.PHONY: sed 
sed:
	$(call sed, {{.name}}, ${NAME})
	$(call sed, {{.name0}}, ${NAME0})
	$(call sed, {{.name1}}, ${NAME1})
	$(call sed, {{.name2}}, ${NAME2})
	$(call sed, {{.name3}}, ${NAME3})
	$(call sed, {{.name4}}, ${NAME4})
	$(call sed, {{.name5}}, ${NAME5})
	$(call sed, {{.name6}}, ${NAME6})
	$(call sed, {{.name7}}, ${NAME7})
	$(call sed, {{.name8}}, ${NAME8})
	$(call sed, {{.name9}}, ${NAME9})
	$(call sed, {{.name10}}, ${NAME10})
	$(call sed, {{.namespace}}, ${NAMESPACE})
	$(call sed, {{.port}}, ${PORT})
	$(call sed, {{.url}}, ${URL})
	$(call sed, {{.image}}, ${IMAGE})
	$(call sed, {{.image0}}, ${IMAGE0})
	$(call sed, {{.image1}}, ${IMAGE1})
	$(call sed, {{.image2}}, ${IMAGE2})
	$(call sed, {{.image3}}, ${IMAGE3})
	$(call sed, {{.image4}}, ${IMAGE4})
	$(call sed, {{.image5}}, ${IMAGE5})
	$(call sed, {{.image6}}, ${IMAGE6})
	$(call sed, {{.image7}}, ${IMAGE7})
	$(call sed, {{.image8}}, ${IMAGE8})
	$(call sed, {{.image10}}, ${IMAGE10})
	$(call sed, {{.image.pull.policy}}, ${IMAGE_PULL_POLICY})
	$(call sed, {{.image.pull.policy2}}, ${IMAGE_PULL_POLICY2})
	$(call sed, {{.labels.key}}, ${LABELS_KEY})
	$(call sed, {{.labels.value}}, ${LABELS_VALUE})
	$(call sed, {{.scripts.cm}}, ${SCRIPTS_CM})
	$(call sed, {{.conf.cm}}, ${CONF_CM})
	$(call sed, {{.env.cm}}, ${ENV_CM})
	$(call sed, {{.proxy}}, ${PROXY})
	$(call sed, {{.discovery.name}}, ${DISCOVERY_NAME})
	$(call sed, {{.discovery.namespace}}, ${DISCOVERY_NAMESPACE})
	$(call sed, {{.object}}, ${OBJECT})
	$(call sed, {{.service.account}}, ${SERVICE_ACCOUNT})
	$(call sed, {{.svc1}}, ${SVC1})
	$(call sed, {{.svc2}}, ${SVC2})
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.schedule}}"?"${SCHEDULE}"?g

deploy: cp sed create
create:
	-kubectl $@ -f ${MANIFEST}/controller.yaml
	-kubectl $@ -f ${MANIFEST}/service.yaml
	-kubectl $@ -f ${MANIFEST}/ingress.yaml

clean: delete
delete:
	-kubectl $@ -f ${MANIFEST}/controller.yaml
	-kubectl $@ -f ${MANIFEST}/service.yaml
	-kubectl $@ -f ${MANIFEST}/ingress.yaml
	#kubectl -n ${NAMESPACE} get pods -o jsonpath="{range .items[*]}{.metadata.name}{'\n'}{end}" | xargs -I {} kubectl -n ${NAMESPACE} $@ pod {} --grace-period=0 --force

run:
	/usr/bin/docker $@ -d -p 80:${PORT} -v /mnt:/mnt --name ${NAME} --restart=on-failure:5 ${IMAGE} /block-chain.py

rm: stop
rm:
	-/usr/bin/docker $@ ${NAME}

stop:
	-/usr/bin/docker $@ ${NAME}
