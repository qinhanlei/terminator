#!/bin/bash

LUAC=./skynet/3rd/lua/luac

luaDirList=(
	"./lualib"
	"./service"
	"./testing"
	"./theone"
	"./training"
)

ignoreFiles=(
	"clustername.lua"
)


function check() {
	if echo "${ignoreFiles[@]}" | grep -w "${1##*/}" &>/dev/null; then
		echo "ignore file: ${1##*/}"
		return 1 # false
	fi
	return 0 # true
}

function compile() {
	for dir in ${luaDirList[@]}
	do
		dirc=$dir"-luac"
		cp -r $dir $dirc
		luaFiles=`find $dirc -name "*.lua"`
		for file in $luaFiles
		do
			if check $file; then
				$LUAC -o $file $file
			fi
		done
	done
	echo "Compile lua files done! "
}

function inplace() {
	for dir in ${luaDirList[@]}
	do
		cp -r $dir $dir"-bak"
		luaFiles=`find $dir -name "*.lua"`
		for file in $luaFiles
		do
			if check $file; then
				$LUAC -o $file $file
			fi
		done
	done
	echo "Inplace compile lua files done! "
}

function recover() {
	for dir in ${luaDirList[@]}
	do
		if [ -d $dir"-bak" ]; then
			rm -rf $dir
			mv $dir"-bak" $dir
		fi
	done
	echo "Recover lua files done! "
}

function clean() {
	for dir in ${luaDirList[@]}
	do
		dirc=$dir"-luac"
		if [ -d $dirc ]; then
			rm -rf $dirc
		fi
	done
}


case "$1" in
	compile)
		clean
		compile
		;;
	inplace)
		inplace
		;;
	recover)
		recover
		;;
	clean)
		clean
		;;
	*)
		clean
		compile
		clean
		;;
esac
