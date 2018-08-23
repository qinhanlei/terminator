#!/bin/sh

if [ ! -d ./logs ]; then
	mkdir -p ./logs
else	
	rm logs/*.log
fi


echo "start testing..."
skynet/skynet testing/config.lua
