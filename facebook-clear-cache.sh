#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
_url="http://localhost/"
sitemap=sitemap.xml


## WELCOME
programTitle "Clean Facebook cache"


## VARIABLES
promptVariable url "Url to rescrape" "$_url" 1 "$@"


## PROGRAM
if [[ "$url" == *$sitemap ]]; then

	confirmOrExit "Really rescrap all pages from ${QuestionBI}${url}${Question} sitemap?"
	url=${url/$sitemap/}
	facebook_cache_clean_by_sitemap $url $sitemap

else

	confirmOrExit "Really rescrap all pages from ${QuestionBI}${url}${Question} page?"
	facebook_cache_clean $url

fi
