#!/usr/bin/env sh

fd --base-directory common -t file --strip-cwd-prefix=always -x cp /{} {}
