#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../_inc/_base.sh

program_title "GeoApify map download"

function uriencode() {
    s="${1}"
    s="${s//'#'/%23}"
    printf %s "$s"
}

function parse_point() {
    local size="$1"
    local diff_lat
    diff_lat=$(eval echo "\${$size[diff_lat]}")
    local diff_lng
    diff_lng=$(eval echo "\${$size[diff_lng]}")
    local latitude
    latitude=$(echo "scale=7; ${2} + $diff_lat*$3" | bc)
    local longitude
    longitude=$(echo "scale=7; ${4} + $diff_lng*$5" | bc)
    printf "lonlat:%s,%s" "$longitude" "$latitude"

    if [[ "$6" != "skip" ]]; then
        printf ";size:%s" "$6"
    fi

    local marker_type="${7}"
    local icon="${9}"
    if [[ "$marker_type" == "box" ]]; then
        marker_type="circle"
    elif [[ "$marker_type" == "marker" ]]; then
        marker_type="awesome"
    fi
    if [[ "$marker_type" != "skip" ]] && [[ "$icon" != "skip" ]]; then
        printf ";type:%s" "$marker_type"
        printf ";icon:%s;icontype:awesome" "$icon"
    fi

    if [[ "${8}" != "skip" ]]; then
        printf ";color:#%s" "${8}"
    fi
    if [[ "${10}" != "" ]]; then
        printf ";text:%s" "${10}"
    fi
    printf "\n"
}

declare -A point_center_hd
function calculate_center_point() {
    point_center_hd[lat_min]=999
    point_center_hd[lat_max]=-999
    point_center_hd[lng_min]=999
    point_center_hd[lng_max]=-999
    for name in "$@"; do
        lat=$(eval echo \${"$name"[lat]})
        lng=$(eval echo \${"$name"[lng]})
        if [[ $(echo "$lat < ${point_center_hd[lat_min]}" | bc) == 1 ]]; then
            point_center_hd[lat_min]=$lat
        fi
        if [[ $(echo "$lat > ${point_center_hd[lat_max]}" | bc) == 1 ]]; then
            point_center_hd[lat_max]=$lat
        fi
        if [[ $(echo "$lng < ${point_center_hd[lng_min]}" | bc) == 1 ]]; then
            point_center_hd[lng_min]=$lng
        fi
        if [[ $(echo "$lng > ${point_center_hd[lng_max]}" | bc) == 1 ]]; then
            point_center_hd[lng_max]=$lng
        fi
    done
    point_center_hd[lat]=$(echo "scale=6; (${point_center_hd[lat_min]} + ${point_center_hd[lat_max]}) / 2.0" | bc)
    point_center_hd[lng]=$(echo "scale=6; (${point_center_hd[lng_min]} + ${point_center_hd[lng_max]}) / 2.0" | bc)
}

function download_maps() {
    for map_key in "${@}"; do
        map_info=$(eval echo \${"$map_key"[@]})
        # echo "» $map_info"
       download_map $map_info
    done
}

function download_map() {
    local name=$1
    display_header "Get $name"
    shift
    local size="$1"
    local zoom
    zoom=$(eval echo "\${$size[zoom]}")
    local width
    width=$(eval echo "\${$size[width]}")
    local height
    height=$(eval echo "\${$size[height]}")
    shift
    local latitude=$1
    shift
    local longitude=$1
    shift
    local pins=($@)
    local file_name
    file_name="${name}.jpg"
    local markers=""
    max=${#pins[@]}
    for i in "${!pins[@]}"; do
        markers="${markers}${pins[$i]}"
        if [[ $(echo "$i < $max - 1" | bc) == 1 ]]; then
            markers="${markers}|"
        fi
    done
    markers=$(uriencode "$markers")
    local url="https://maps.geoapify.com/v1/staticmap?style=osm-carto&center=lonlat:${longitude},${latitude}&zoom=${zoom}&width=${width}&height=${height}&apiKey=${GEOAPIFY_API_KEY}&marker=${markers}"
    echo $url
    curl -vs -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:87.0) Gecko/20100101 Firefox/87.0' $url >${file_name}
}

#calculate_center_point
#map_wszystko=(
#    "mapa" "size_full_all" "${point_center_hd[lat]}" "${point_center_hd[lng]}"
#)
#maps=(
#    map_wszystko
#)
#download_maps ${maps[@]}
