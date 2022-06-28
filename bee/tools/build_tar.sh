#!/bin/bash
(cd ../..; tar -pcz --exclude='.env' -f ./bee/install.tar.gz bee)