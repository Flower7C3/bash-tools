#!/usr/bin/env bash

source `dirname $0`/_base.sh


_url="http://localhost/"
sitemap=sitemap.xml


clear
programTitle "Clean facebook cache"

promptVariable url "Url to rescrape" "$_url" 1 "$@"

if [[ "$url" == *$sitemap ]]; then

	confirmOrExit "Really rescrap all pages from ${BIYellow}${url}${Color_Off} sitemap${Color_Off}?"
	url=${url/$sitemap/}
	facebook_cache_clean_by_sitemap $url $sitemap

else

	confirmOrExit "Really rescrap all pages from ${BIYellow}${url}${Color_Off} page${Color_Off}?"
	facebook_cache_clean $url

fi
