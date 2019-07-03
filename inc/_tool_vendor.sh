###############################################################
### Facebook cache
### generate access token at https://developers.facebook.com/tools/explorer page
###############################################################

function facebook_cache_clean_by_sitemap {
    local access_token=$1
    local base_url=${2:-"http://localhost"}
    local sitemap_path=${3:-"/sitemap.xml"}

    printf "${color_info_b}Clean facebook cache for ${color_info_h}${base_url}${sitemap_path}${color_info_b} sitemap ${color_info} \n"
    curl -s ${base_url}${sitemap_path} | egrep -o "${base_url}[^ \"()\<>]*" | while read url;
    do
        if [[ "$url" == *sitemap*.xml ]]; then
            facebook_cache_clean_by_sitemap ${access_token} ${base_url} ${url/$base_url/}
        else
            facebook_cache_clean ${access_token} ${url}
        fi
    done
}

# more info in docs https://developers.facebook.com/docs/graph-api/reference/v3.1/url
function facebook_cache_clean {
    local access_token=$1
    local url=${2:-"http://localhost"}

    printf "${color_info_b}Clean facebook cache for ${color_info_h}${url}${color_info_b} page${color_off} \n"
    curl -s -X POST \
        -F "id=${url}" \
        -F "scrape=true" \
        -F "access_token=${access_token}" \
        "https://graph.facebook.com" | jq
    echo ""
}
