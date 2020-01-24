DRUID_VERSION ?= 0.16.1-incubating
VER_TAG=anskarl/druid:$(DRUID_VERSION)
LATEST_TAG=anskarl/druid:latest

image:
	@echo "Creating image with tags '$(VER_TAG)' and '$(LATEST_TAG)'"
	docker build -t $(VER_TAG) --build-arg ARG_DRUID_VERSION=$(DRUID_VERSION) -f ./src/Dockerfile.druid ./src
	docker tag $(VER_TAG) $(LATEST_TAG)

push:
	@echo "Pushing image with tags '$(VER_TAG)' and '$(LATEST_TAG)'"
	docker push $(VER_TAG) && docker push $(LATEST_TAG)

clean:
	@echo "Deleting image with tags '$(VER_TAG)' and '$(LATEST_TAG)'"
	docker rmi $(VER_TAG)
	docker rmi $(LATEST_TAG)
