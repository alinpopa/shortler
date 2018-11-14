.PHONY: build run postgres influxdb-dev influxdb stop run-all

all: build

VSN := $(shell git describe --always --dirty)

build:
	docker build -t shortler:$(VSN) -f Dockerfile ../

run: build
	VSN=$(VSN) docker-compose -f docker-compose.yml up -d shortler

run-all: build
	VSN=$(VSN) docker-compose -f docker-compose.yml up

postgres:
	VSN=$(VSN) docker-compose -f docker-compose.yml up -d postgres

influxdb:
	VSN=$(VSN) docker-compose -f docker-compose.yml up -d influxdb

influxdb-dev:
	VSN=$(VSN) docker-compose -f docker-compose.yml up -d influxdbdev

stop:
	VSN=$(VSN) docker-compose -f docker-compose.yml stop
