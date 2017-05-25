###############################################################
### Facebook cache
###############################################################

function facebook_cache_clean_by_sitemap {
    local baseURL=${1:-http://localhost/}
    local sitemapFile=${2:-sitemap.xml}

    printf "${InfoB}Clean facebook cache for ${InfoBI}${baseURL}${InfoB} ${Info} \n"
    wget -q ${baseURL}${sitemapFile} --no-check-certificate --no-cache -O - | egrep -o "${baseURL}[^ \"()\<>]*" | while read url;
    do
        facebook_cache_clean $url
    done
}

function facebook_cache_clean {
    local url=${1:-http://localhost/}

    printf "${InfoB}Clean facebook cache for ${InfoBI}${url}${InfoB} page${Color_Off} \n"
    curl -X POST \
        -F "id=${url}" \
        -F "scrape=true" \
        "https://graph.facebook.com"
    echo ""
}
