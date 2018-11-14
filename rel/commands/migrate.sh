#!/usr/bin/env sh

release_ctl eval --mfa "Tasks.Release.migrate/1" --argv -- "$@"
