SOURCE_DIR := $(shell pwd)/../..
DOCKER_IMAGE_DEVDOC := almighty-devdoc

# The IS_JENKINS will be either "yes" or "no" depending on if
# make is executed inside of Jenkins or locally.
ifneq ($(BUILD_TAG),)
	IS_JENKINS := "yes"
	# If running in Jenkins we don't allow for interactively running the container
	DOCKER_RUN_INTERACTIVE_SWITCH := 
else 
	IS_JENKINS := "no"
	# If not running in Jenkins we allow for interactively running the container
	DOCKER_RUN_INTERACTIVE_SWITCH :=  -i
endif

# The workspace environment is set by Jenkins and defaults to /tmp if not set
WORKSPACE ?= /tmp
BUILD_DIR := $(WORKSPACE)/almighty-devdoc-linux-build
# The BUILD_TAG environment variable will be set by jenkins
# to reflect jenkins-${JOB_NAME}-${BUILD_NUMBER}
BUILD_TAG ?= almighty-devdoc-local-build
CONTAINER_NAME := $(BUILD_TAG)

# Call with $(call colorecho "hi" " there")
define printlog
	@tput setaf 6
	@echo $1
	@tput sgr0
endef

.PHONY: all
all: build

.PHONY: docker-image-devdoc
docker-image-devdoc:
	$(call printlog,"Building docker image $(DOCKER_IMAGE_DEVDOC)")
	docker build -t $(DOCKER_IMAGE_DEVDOC) .

.PHONY: build-dir
build-dir:
	$(call printlog,"Creating build directory $(BUILD_DIR)")
	mkdir -p $(BUILD_DIR)

.PHONY: clean
clean:
	$(call printlog,"Cleaning build directory $(BUILD_DIR)")
	rm -rf $(BUILD_DIR)
	
.PHONY: build
build: build-dir docker-image-devdoc
	$(call prinlog,"Building with container $(CONTAINER_NAME) inside of $(BUILD_DIR)")
	# TODO (kkleine) Remove interactive switch when running in Jenkins 
	docker run \
		-t \
		$(DOCKER_RUN_INTERACTIVE_SWITCH) \
		--rm \
		--name="$(CONTAINER_NAME)" \
		-v $(SOURCE_DIR):/source-dir:ro \
		-v $(BUILD_DIR):/build-dir:rw \
		-e USER=$(USER) \
		-e USERID=$(shell id -u $(USER)) \
		$(DOCKER_IMAGE_DEVDOC) \
		/source-dir/jenkins/linux/build.sh /source-dir /build-dir


