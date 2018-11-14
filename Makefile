.PHONY: build test release release-docker run clean clean-deps

all: test

build:
	mix deps.get && mix compile

test: build
	mix test

release:
	MIX_ENV=prod mix do deps.get, release

release-docker:
	MIX_ENV=docker mix do deps.get, release

run:
	MIX_ENV=prod iex -S mix

clean:
	-rm -rf _build

clean-deps:
	-rm -rf deps
