#
# Makefile for Patched Docker CE Build
#

NAME := docker-ce
VERSION := 20.10.9
RELEASE := 3
ENV := el8

NEXT_VERSION := $(VERSION).1
NEXT_RELEASE := 1

SRPM := $(NAME)-$(VERSION)-$(RELEASE).el8.src.rpm
SRPM_URL := https://download.docker.com/linux/centos/8/source/stable/Packages/$(SRPM)

GO_VERSION := 1.16.8
GO_TARBALL := go$(GO_VERSION).linux-amd64.tar.gz
GO_URL := https://golang.org/dl/$(GO_TARBALL)
GO_DIR := go
GO_PATH := $(shell cd `pwd` && pwd)/$(GO_DIR)
GO_BIN := $(GO_PATH)/bin
# Build process leftovers
GO_DROPPINGS := /go /usr/local/bin/docker-*



default: build


$(GO_TARBALL):
	curl --location $(GO_URL) > "$@"
TO_CLEAN += $(GO_TARBALL)

$(GO_DIR): $(GO_TARBALL)
	rm -rf "$@"
	tar xzf "$<"
TO_CLEAN += $(GO_DIR)


$(SRPM):
	curl -s -o '$@' '$(SRPM_URL)'
TO_CLEAN += $(SRPM)


$(NAME): $(SRPM) $(GO_DIR)
	mkdir -p '$@'
	rpm2cpio '$<' | (cd '$@' && cpio -i)
	cp changes/* '$@'
	sed -i \
		-e 's/%{_version}/$(NEXT_VERSION)/g' \
		-e 's/%{_release}/$(NEXT_RELEASE)/g' \
		'$@/$(NAME).spec'
	echo 'include make/generic-rpm.make' > '$@/Makefile'
TO_CLEAN += $(NAME)


RPM_DIR=rpm
build: $(NAME)
	rm -rf $(GO_DROPPINGS)
	PATH=$(GO_BIN):$$PATH \
	    GOPATH=$(GO_PATH) \
	    GO111MODULE=off \
	    $(MAKE) -C $(NAME) clean build
	mkdir -p "$(RPM_DIR)"
	cp $(NAME)/$(NAME)*.rpm "$(RPM_DIR)"
TO_CLEAN += $(RPM_DIR) $(GO_DROPPINGS)


clean:
	rm -rf $(TO_CLEAN)
	find . -name "*~" | xargs rm -rf
