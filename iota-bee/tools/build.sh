#!/bin/bash
mkdir -p ../build && tar -pcz --exclude='.env' --exclude='build' --exclude='build_tar.sh' --exclude='data' -f ../build/install.tar.gz ../*