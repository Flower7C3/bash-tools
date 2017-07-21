#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
_url="http://localhost/"
sitemap=sitemap.xml


## WELCOME
program_title "Clean Facebook cache"


## VARIABLES
prompt_variable url "Url to rescrape" "$_url" 1 "$@"


## PROGRAM
if [[ "$url" == *$sitemap ]]; then

	confirm_or_exit "Really rescrap all pages from ${color_question_h}${url}${color_question} sitemap?"
	url=${url/$sitemap/}
	facebook_cache_clean_by_sitemap $url $sitemap

else

	confirm_or_exit "Really rescrap all pages from ${color_question_h}${url}${color_question} page?"
	facebook_cache_clean $url

fi
