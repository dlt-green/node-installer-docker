#!/bin/bash
mkdir -p ../build
tar -pcz --exclude='.env' --exclude='build' -f ../build/install.tar.gz ../../bee