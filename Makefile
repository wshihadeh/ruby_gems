# Image name
NAME := rubygems
# Project namespace: adib by default
NAMESPACE ?= wshihadeh
# Docker registry
REGISTRY ?= index.docker.io
# Image candidate tag of build process: release or nightly
BRANCH ?= $$(git symbolic-ref --short HEAD)
IMAGE_TAG ?= $$(echo ${BRANCH} | tr / _)
# Fetch the latest commit hash
COMMIT_HASH := $$(git rev-parse HEAD)
# Docker image reference
IMG := ${REGISTRY}/${NAMESPACE}/${NAME}
# Get ruby version
RUBY_VERSION := $$(<.ruby-version)
# Get ruby gemset name
RUBY_GEMSET := $$(<.ruby-gemset)

# Set build parameters
BUILD_PARAMS := --pull --label com.revision=${COMMIT_HASH}

# Make sure recipes are always executed
.PHONY: config build push clean

# Make the necessary configuration for the build
config:
	@echo "Running configuration ..."; \
	rvm --create ${RUBY_VERSION}@${RUBY_GEMSET} && rvm info ruby,environment; \
	rvm use ${RUBY_VERSION}@${RUBY_GEMSET}; \
	gem install bundler -v $$(tail -1 Gemfile.lock); \
	rm -rf .bundle; \
	rm -rf vendor/cache; \
	bundle package --all-platforms --all --no-install ; \
	rm -rf .bundle;

# Build and tag Docker image
build:
	@echo "Building Docker Images ..."
	docker build ${BUILD_PARAMS} -t ${IMG}:${COMMIT_HASH} . ; \
	docker tag ${IMG}:${COMMIT_HASH} ${IMG}:${IMAGE_TAG};

# Push Docker image
push:
	@echo "Pushing Docker images ..."
	docker push ${IMG}:${COMMIT_HASH}; \
	docker push ${IMG}:${IMAGE_TAG};

auto_build: config build push clean

start:
	docker run --rm -it -p 8080:8080 ${IMG}:${COMMIT_HASH} web
# Clean up the created images locally and remove rvm gemset
clean:
	@echo "Cleaning Docker images ..."
	docker rmi -f ${IMG}:${IMAGE_TAG}; \
	docker rmi -f ${IMG}:${COMMIT_HASH}; \
	rvm --force gemset delete ruby-${RUBY_VERSION}@${RUBY_GEMSET}_${BRANCH_TAG}
