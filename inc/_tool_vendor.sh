###############################################################
### Facebook cache
###############################################################

function facebook_cache_clean_by_sitemap {
    local baseURL=${1:-http://localhost/}
    local sitemapFile=${2:-sitemap.xml}

    printf "${color_info_b}Clean facebook cache for ${color_info_h}${baseURL}${color_info_b} ${color_info} \n"
    wget -q ${baseURL}${sitemapFile} --no-check-certificate --no-cache -O - | egrep -o "${baseURL}[^ \"()\<>]*" | while read url;
    do
        facebook_cache_clean $url
    done
}

function facebook_cache_clean {
    local url=${1:-http://localhost/}

    printf "${color_info_b}Clean facebook cache for ${color_info_h}${url}${color_info_b} page${color_off} \n"
    curl -X POST \
        -F "id=${url}" \
        -F "scrape=true" \
        "https://graph.facebook.com"
    echo ""
}
