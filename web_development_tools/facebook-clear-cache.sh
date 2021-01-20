#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../_base.sh


## CONFIG
_base_url="http://localhost"
_sitemap_path=""


## WELCOME
program_title "Clean Facebook cache"


## VARIABLES
prompt_variable access_token "Facebook access token (generate one at https://developers.facebook.com/tools/explorer page)" "" 1 "$@"
prompt_variable base_url "URL to rescrape" "$_base_url" 2 "$@"
prompt_variable sitemap_path "Sitemap path" "$_sitemap_path" 3 "$@"


## PROGRAM
if [[ "$sitemap_path" != "" ]]; then

	confirm_or_exit "Really rescrap all pages from ${COLOR_QUESTION_H}${base_url}${sitemap_path}${COLOR_QUESTION} sitemap?"
	facebook_cache_clean_by_sitemap ${access_token} ${base_url} ${sitemap_path}

else

	confirm_or_exit "Really rescrap all pages from ${COLOR_QUESTION_H}${base_url}${COLOR_QUESTION} page?"
	facebook_cache_clean ${access_token} ${base_url}

fi
