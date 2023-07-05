IMAGE ?= koyeb/log-exporter
VERSION ?= $(shell git rev-parse --short HEAD)
DOCKER ?= docker
LOCAL_IMAGE := log-exporter

build-common:
	$(DOCKER) build -t $(LOCAL_IMAGE) .

build-base: build-common
	$(DOCKER) tag $(LOCAL_IMAGE) $(IMAGE):$(VERSION)

build-%:
	$(DOCKER) build -t $(IMAGE):$(VERSION)-$* ./specialized/$*

build: build-base build-splunk build-webhook build-elastic

push-base:
	$(DOCKER) push $(IMAGE):$(VERSION)

push-%:
	$(DOCKER) push $(IMAGE):$(VERSION)-$*

push: push-base push-splunk push-webhook push-elastic
