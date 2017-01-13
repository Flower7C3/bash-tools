#!/usr/bin/env bash

pwd
php app/console doctrine:migrations:execute --down -n $1
php app/console doctrine:migrations:execute --up -n $1
