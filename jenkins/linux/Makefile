SOURCE_DIR := $(shell pwd)/../..
DOCKER_IMAGE_DEVDOC := almighty-devdoc

# The IS_JENKINS will be set depending on if
# make is executed inside of Jenkins or locally not
ifneq ($(BUILD_TAG),)
	IS_JENKINS := "yes"
	# If running in Jenkins we don't allow for interactively running the container
	DOCKER_RUN_INTERACTIVE_SWITCH :=
else 
	IS_JENKINS :=
	# If not running in Jenkins we allow for interactively running the container
	DOCKER_RUN_INTERACTIVE_SWITCH :=  -i
endif

# The workspace environment is set by Jenkins and defaults to /tmp if not set
WORKSPACE ?= /tmp
BUILD_DIR := $(WORKSPACE)/almighty-devdoc-linux-build
# The BUILD_TAG environment variable will be set by jenkins
# to reflect jenkins-${JOB_NAME}-${BUILD_NUMBER}
BUILD_TAG ?= almighty-devdoc-local-build
DOCKER_CONTAINER_NAME := $(BUILD_TAG)

.PHONY: all
all: build

.PHONY: docker-image-devdoc
docker-image-devdoc:
	@echo "Building docker image $(DOCKER_IMAGE_DEVDOC)"
	docker build -t $(DOCKER_IMAGE_DEVDOC) .

.PHONY: build-dir
build-dir:
	@echo "Creating build directory $(BUILD_DIR)"
	mkdir -p $(BUILD_DIR)

.PHONY: clean-docker-container
clean-docker-container:
	@echo "Removing container named \"$(DOCKER_CONTAINER_NAME)\" (if any)"
ifneq ($(strip $(shell docker ps -qa --filter "name=$(DOCKER_CONTAINER_NAME)")),) 
	docker rm -f $(DOCKER_CONTAINER_NAME)
else
	@echo "No container named \"$(DOCKER_CONTAINER_NAME)\" to remove"
endif

.PHONY: clean-build-dir
clean-build-dir:
	@echo "Cleaning build directory $(BUILD_DIR)"
	rm -rf $(BUILD_DIR)

.PHONY: clean
clean: clean-docker-container clean-build-dir
	
.PHONY: build
build: build-dir docker-image-devdoc
	@echo "Building with container $(CONTAINER_NAME) inside of $(BUILD_DIR)"
	# TODO (kkleine) Remove interactive switch when running in Jenkins 
	docker run \
		-t \
		$(DOCKER_RUN_INTERACTIVE_SWITCH) \
		--rm \
		--name="$(DOCKER_CONTAINER_NAME)" \
		-v $(SOURCE_DIR):/source-dir:ro \
		-v $(BUILD_DIR):/build-dir:rw \
		-e USER=$(USER) \
		-e USERID=$(shell id -u $(USER)) \
		$(DOCKER_IMAGE_DEVDOC) \
		/source-dir/jenkins/linux/build.sh /source-dir /build-dir


