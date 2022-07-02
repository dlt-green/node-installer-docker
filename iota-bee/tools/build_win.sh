#!/bin/bash
mkdir -p ../build && chown $USER ../build && docker run --rm -v $(pwd)/../../iota-bee:/iota-bee -w="/iota-bee/tools" alpine sh ./build.sh