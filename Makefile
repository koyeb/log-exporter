IMAGE ?= koyeb/log-exporter
VERSION ?= $(shell git rev-parse --short HEAD)
DOCKER ?= docker
LOCAL_IMAGE := log-exporter
KOYEB_CLI_VERSION ?= v5.3.2

build-common:
	$(DOCKER) build \
		--platform linux/amd64 \
		--pull \
		--build-arg KOYEB_CLI_VERSION=$(KOYEB_CLI_VERSION) \
		-t $(LOCAL_IMAGE) .

build-base: build-common
	$(DOCKER) tag $(LOCAL_IMAGE) $(IMAGE):$(VERSION)

build-%:
	$(DOCKER) build \
		--platform linux/amd64 \
		--build-arg BASE_IMG=$(LOCAL_IMAGE) \
		-t $(IMAGE):$(VERSION)-$* ./specialized/$*

build: build-base build-splunk build-webhook build-elastic

push-base:
	$(DOCKER) push $(IMAGE):$(VERSION)

push-%:
	$(DOCKER) push $(IMAGE):$(VERSION)-$*

push: push-base push-splunk push-webhook push-elastic
