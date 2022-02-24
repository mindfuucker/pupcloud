.PHONY: list
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

cleanup:
	rm -rf bin
	rm -rf web-ui/node_modules
	rm -rf web-ui/public/build

build-prepare:
	make cleanup
	mkdir bin

build-ui:
	make build-prepare
	cd web-ui && npm install && npm run build
	rm -rf src/static/*
	cp -r web-ui/public/* src/static/

build-static:
	make build-ui
	cd src; go build -a -tags netgo,osusergo -ldflags '-w -extldflags "-static"' -o ../bin/pupcloud

zbuild-static:
	make build-static
	cd bin; 7zr a -mx9 -t7z pupcloud-v0.0.1-`uname -s|tr '[:upper:]' '[:lower:]'`-`uname -m`.7z pupcloud

build:
	make build-ui
	cd src; go build -o ../bin/pupcloud

zbuild:
	make build
	cd bin; 7zr a -mx9 -t7z pupcloud-v0.0.1-`uname -s|tr '[:upper:]' '[:lower:]'`-`uname -m`.7z pupcloud

run:
	make build
	bin/pupcloud -r testFs/

run-ui:
	cd web-ui && npm install && npm run dev
