#!/bin/bash

if [ -d ./beaglev-ahead-linux ] ; then
	cd ./beaglev-ahead-linux/
	git reset HEAD --hard
	cd ../
fi

git submodule init && git submodule sync && git submodule update --remote

if [ -d ./opensbi ] ; then
	rm -rf ./opensbi || true
fi

git clone git@git.beagleboard.org:beaglev-ahead/opensbi.git
