#!/bin/bash

git reset HEAD --hard
git submodule init && git submodule sync && git submodule update --remote
