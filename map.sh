#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## VARIABLES
## https://www.openstreetmap.org/export
_ZOOM='15'
_GEO_LONG_W="20,2008" #"20,1376"
_GEO_LAT_S="49,9817" #"49,9552"
_GEO_LONG_E="20,4651" #"20,4984"
_GEO_LAT_N="50,0836" #"50,1267"
_MAP_TYPE="standard"
_SAVE_DIR_NAME="${HOME}/Pictures/"
map_server="a"

declare -A map_url_pattern
map_url_pattern[standard]="http://%s.tile.openstreetmap.org/%s/%s/%s.png"
map_url_pattern[cycle]="http://%s.tile.opencyclemap.org/cycle/%s/%s/%s.png"
declare -A map_zomes
map_zomes[standard]="0 1 2 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19"
map_zomes[cycle]="0 1 2 4 5 6 7 8 9 10 11 12 14 15 16 17 18"
temp_dir_path="/tmp/"
map_pattern="%smap--%s-%s-%s-%s--z%s--%s.png"
map_x_pattern="${temp_dir_path}partial_map--x%s--z%s--%s.png"
map_xy_pattern="${temp_dir_path}partial_map--x%s--y%s--z%s--%s.png"



## WELCOME
program_title "Download OSM map to PNG file"

prompt_variable_fixed MAP_TYPE "Map type" "$_MAP_TYPE" "standard cycle" 1 "$@"
prompt_variable_fixed ZOOM "Map zoom" "$_ZOOM" "${map_zomes[$MAP_TYPE]}" 2 "$@"
prompt_variable GEO_LONG_W "Map max point on West" "$_GEO_LONG_W" 3 "$@"
prompt_variable GEO_LAT_S "Map max point on South" "$_GEO_LAT_S" 4 "$@"
prompt_variable GEO_LONG_E "Map max point on East" "$_GEO_LONG_E" 5 "$@"
prompt_variable GEO_LAT_N "Map max point on North" "$_GEO_LAT_N" 6 "$@"
prompt_variable SAVE_DIR_NAME "Save dir name" "$_SAVE_DIR_NAME" 7 "$@"
map=$(printf "$map_pattern" "$SAVE_DIR_NAME" "$GEO_LONG_W" "$GEO_LAT_S" "$GEO_LONG_E" "$GEO_LAT_N" "$MAP_TYPE" "$ZOOM")



## PROGRAM
confirm_or_exit "Start downloading as ${color_question_h}${map}${color_question} file?"

source "$(dirname ${BASH_SOURCE})/inc/_osm.sh"
xtile_min=$(long2xtile ${GEO_LONG_W/./,} ${ZOOM})
xtile_max=$(long2xtile ${GEO_LONG_E/./,} ${ZOOM})
ytile_min=$(lat2ytile ${GEO_LAT_N/./,} ${ZOOM})
ytile_max=$(lat2ytile ${GEO_LAT_S/./,} ${ZOOM})
xtile_amount=$((xtile_max - xtile_min))
ytile_amount=$((ytile_max - ytile_min))
tile_amount=$((xtile_amount * ytile_amount + ytile_amount))

for ((xtile=$xtile_min; xtile<=$xtile_max; xtile++)); do
	map_tile_x=$(printf "$map_x_pattern" ${xtile} ${MAP_TYPE} ${ZOOM})
	xtile_index=$((xtile - xtile_min))
	for ((ytile=$ytile_min; ytile<=$ytile_max; ytile++)); do
		url=$(printf "${map_url_pattern[$MAP_TYPE]}" ${map_server} ${ZOOM} ${xtile} ${ytile})
		map_tile_xy=$(printf "$map_xy_pattern" ${xtile} ${ytile} ${MAP_TYPE} ${ZOOM})
		ytile_index=$((ytile - ytile_min))
		tile_index=$((xtile_index * ytile_amount + ytile_index))
		tile_percent=$((100 * tile_index / tile_amount))
		printf "${color_success}Get ${color_success_b}%s/%s${color_success} partial of ${color_success_b}%s${color_success} map with ${color_success_b}%d${color_success} zoom at ${color_success_b}x=%d${color_success} and ${color_success_b}y=%d${color_success} (%.0f%%)${color_off}\n" "$tile_index" "$tile_amount" "$MAP_TYPE" "$ZOOM" "$xtile" "$ytile" "$tile_percent"
		curl -s ${url} > ${map_tile_xy}
	done
done

for ((xtile=$xtile_min; xtile<=$xtile_max; xtile++)); do
	map_tile_x=$(printf "$map_x_pattern" ${MAP_TYPE} ${ZOOM} ${xtile})
	xtile_index=$((xtile - xtile_min))
	for ((ytile=$ytile_min; ytile<=$ytile_max; ytile++)); do
		url=$(printf "${map_url_pattern[$MAP_TYPE]}" ${map_server} ${ZOOM} ${xtile} ${ytile})
		map_tile_xy=$(printf "$map_xy_pattern" ${MAP_TYPE} ${ZOOM} ${xtile} ${ytile})
		ytile_index=$((ytile - ytile_min))
		tile_index=$((xtile_index * ytile_amount + ytile_index))
		tile_percent=$((100 * tile_index / tile_amount))
		printf "${color_success}Concat partial ${color_success_b}%s/%s${color_success} with ${color_success_b}x=%d${color_success} and ${color_success_b}y=%d${color_success} (%.0f%%)${color_off}\n" "$tile_index" "$tile_amount" "$xtile" "$ytile" "$tile_percent"
		if [[ -e "$map_tile_x" ]]; then
			convert ${map_tile_x} ${map_tile_xy} -append ${map_tile_x}
		else
			cp ${map_tile_xy} ${map_tile_x}
		fi
		rm ${map_tile_xy}
	done
done

if [[ -e "$map" ]]; then
	rm ${map}
fi
mkdir -p ${SAVE_DIR_NAME}

for ((xtile=$xtile_min; xtile<=$xtile_max; xtile++)); do
	map_tile_x=$(printf "$map_x_pattern" ${MAP_TYPE} ${ZOOM} ${xtile})
	xtile_index=$((xtile - xtile_min))
	xtile_percent=$((100 * xtile_index / xtile_amount))
	printf "${color_success}Concat partial ${color_success_b}%s/%s${color_success} with ${color_success_b}x=%d${color_success} to main map (%.0f%%)${color_off}\n" "$xtile_index" "$xtile_amount" "$xtile" "$xtile_percent"
	if [[ -e "$map" ]]; then
		convert ${map} ${map_tile_x} +append ${map}
	else
		cp ${map_tile_x} ${map}
	fi
	rm ${map_tile_x}
done

printf "${color_success_b}Saved as ${color_success_h}%s${color_success_b}${color_success}\n" "$map"

display_new_line
