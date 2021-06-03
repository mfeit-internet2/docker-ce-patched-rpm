#
# Makefile for Patched Docker CE Build
#

NAME := docker-ce
VERSION := 20.10.7
RELEASE := 3
ENV := el8

NEXT_VERSION := $(VERSION).1
NEXT_RELEASE := 1

SRPM := $(NAME)-$(VERSION)-$(RELEASE).el8.src.rpm
SRPM_URL := https://download.docker.com/linux/centos/8/source/stable/Packages/$(SRPM)

default: build


$(SRPM):
	curl -s -o '$@' '$(SRPM_URL)'
TO_CLEAN += $(SRPM)


$(NAME): $(SRPM)
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
	$(MAKE) -C $(NAME) clean build
	mkdir -p "$(RPM_DIR)"
	cp $(NAME)/$(NAME)*.rpm "$(RPM_DIR)"
TO_CLEAN += $(RPM_DIR)


clean:
	rm -rf $(TO_CLEAN)
	find . -name "*~" | xargs rm -rf
