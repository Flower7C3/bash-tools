#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE})
branch=${1:-'master'}
git checkout -- .
git pull origin $branch
git submodule update --init --recursive
git submodule foreach git pull origin $branch
