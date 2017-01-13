#!/usr/bin/env bash

pwd
php app/console doctrine:database:drop --force
php app/console doctrine:database:create
