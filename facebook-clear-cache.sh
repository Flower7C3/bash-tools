#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


_url="http://localhost/"
sitemap=sitemap.xml


clear
programTitle "Clean Facebook cache"

promptVariable url "Url to rescrape" "$_url" 1 "$@"

if [[ "$url" == *$sitemap ]]; then

	confirmOrExit "Really rescrap all pages from ${QuestionBI}${url}${Question} sitemap?"
	url=${url/$sitemap/}
	facebook_cache_clean_by_sitemap $url $sitemap

else

	confirmOrExit "Really rescrap all pages from ${QuestionBI}${url}${Question} page?"
	facebook_cache_clean $url

fi
