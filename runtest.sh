#!/bin/sh

rm logs/*.log

export NODE_NAME=test
echo "start "$NODE_NAME"..."
skynet/skynet test/config.lua
