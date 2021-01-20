# https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
# https://stackoverflow.com/a/26665998/2910183
function rgb_to_ansi256() {
    local r=$1
    local g=$2
    local b=$3

    if [[ "$r" == "$g" && "$g" == "$b" ]]; then
        ansi=1
        if [[ "$r" < 8 ]]; then
            ansi=16
        elif [[ "$r" > 248 ]]; then
            ansi=231
        else
            ansi=$((((($r - 8) / 247) * 24) + 232))
        fi
    else
        local r_index=$(((36 * ($r / 255 * 5))))
        local g_index=$(((6 * ($g / 255 * 5))))
        local b_index=$((($b / 255 * 5)))
        ansi=$((16 + $r_index + $g_index + $b_index))
    fi
    printf ${ansi%.*}
}

function rgb_foreground() {
    local r=$1
    local g=$2
    local b=$3
    local code=$(rgb_to_ansi256 $r $g $b)
    printf "\033[38;5;%sm" "$code"
}

function rgb_background() {
    local r=$1
    local g=$2
    local b=$3
    local code=$(rgb_to_ansi256 $r $g $b)
    printf "\033[48;5;%sm" "$code"
}

# Reset
declare -r COLOR_OFF='\033[0m'             # Text Reset

# Regular Colors
declare -r COLOR_BLACK='\033[0;30m'        # Black
declare -r COLOR_RED='\033[0;31m'          # Red
declare -r COLOR_GREEN='\033[0;32m'        # Green
declare -r COLOR_YELLOW='\033[0;33m'       # Yellow
declare -r COLOR_BLUE='\033[0;34m'         # Blue
declare -r COLOR_PURPLE='\033[0;35m'       # Purple
declare -r COLOR_CYAN='\033[0;36m'         # Cyan
declare -r COLOR_WHITE='\033[0;37m'        # White

# Bold
declare -r COLOR_BLACK_B='\033[1;30m'      # Black
declare -r COLOR_RED_B='\033[1;31m'        # Red
declare -r COLOR_GREEN_B='\033[1;32m'      # Green
declare -r COLOR_YELLOW_B='\033[1;33m'     # Yellow
declare -r COLOR_BLUE_B='\033[1;34m'       # Blue
declare -r COLOR_PURPLE_B='\033[1;35m'     # Purple
declare -r COLOR_CYAN_B='\033[1;36m'       # Cyan
declare -r COLOR_WHITE_B='\033[1;37m'      # White

# Underline
declare -r COLOR_BLACK_U='\033[4;30m'      # Black
declare -r COLOR_RED_U='\033[4;31m'        # Red
declare -r COLOR_GREEN_U='\033[4;32m'      # Green
declare -r COLOR_YELLOW_U='\033[4;33m'     # Yellow
declare -r COLOR_BLUE_U='\033[4;34m'       # Blue
declare -r COLOR_PURPLE_U='\033[4;35m'     # Purple
declare -r COLOR_CYAN_U='\033[4;36m'       # Cyan
declare -r COLOR_WHITE_U='\033[4;37m'      # White

# Background
declare -r COLOR_BLACK_BG='\033[40m'       # Black
declare -r COLOR_RED_BG='\033[41m'         # Red
declare -r COLOR_GREEN_BG='\033[42m'       # Green
declare -r COLOR_YELLOW_BG='\033[43m'      # Yellow
declare -r COLOR_BLUE_BG='\033[44m'        # Blue
declare -r COLOR_PURPLE_BG='\033[45m'      # Purple
declare -r COLOR_CYAN_BG='\033[46m'        # Cyan
declare -r COLOR_WHITE_BG='\033[47m'       # White

# High Intensity
declare -r COLOR_BLACK_I='\033[0;90m'      # Black
declare -r COLOR_RED_I='\033[0;91m'        # Red
declare -r COLOR_GREEN_I='\033[0;92m'      # Green
declare -r COLOR_YELLOW_I='\033[0;93m'     # Yellow
declare -r COLOR_BLUE_I='\033[0;94m'       # Blue
declare -r COLOR_PURPLE_I='\033[0;95m'     # Purple
declare -r COLOR_CYAN_I='\033[0;96m'       # Cyan
declare -r COLOR_WHITE_I='\033[0;97m'      # White

# Bold High Intensity
declare -r COLOR_BLACK_H='\033[1;90m'      # Black
declare -r COLOR_RED_H='\033[1;91m'        # Red
declare -r COLOR_GREEN_H='\033[1;92m'      # Green
declare -r COLOR_YELLOW_H='\033[1;93m'     # Yellow
declare -r COLOR_BLUE_H='\033[1;94m'       # Blue
declare -r COLOR_PURPLE_H='\033[1;95m'     # Purple
declare -r COLOR_CYAN_H='\033[1;96m'       # Cyan
declare -r COLOR_WHITE_H='\033[1;97m'      # White

# High Intensity backgrounds
declare -r COLOR_BLACK_BG_I='\033[0;100m'  # Black
declare -r COLOR_RED_BG_I='\033[0;101m'    # Red
declare -r COLOR_GREEN_BG_I='\033[0;102m'  # Green
declare -r COLOR_YELLOW_BG_I='\033[0;103m' # Yellow
declare -r COLOR_BLUE_BG_I='\033[0;104m'   # Blue
declare -r COLOR_PURPLE_BG_I='\033[0;105m' # Purple
declare -r COLOR_CYAN_BG_I='\033[0;106m'   # Cyan
declare -r COLOR_WHITE_BG_I='\033[0;107m'  # White

# Events

declare -r COLOR_DEFAULT=${COLOR_WHITE}
declare -r COLOR_DEFAULT_U=${COLOR_WHITE_U}
declare -r COLOR_DEFAULT_B=${COLOR_WHITE_B}
declare -r COLOR_DEFAULT_H=${COLOR_WHITE_H}
declare -r COLOR_DEFAULT_I=${COLOR_WHITE_I}
declare -r COLOR_DEFAULT_BG=${COLOR_WHITE_BG}

declare -r COLOR_LOG=${COLOR_PURPLE}
declare -r COLOR_LOG_U=${COLOR_PURPLE_U}
declare -r COLOR_LOG_B=${COLOR_PURPLE_B}
declare -r COLOR_LOG_H=${COLOR_PURPLE_H}
declare -r COLOR_LOG_I=${COLOR_PURPLE_I}
declare -r COLOR_LOG_BG=${COLOR_PURPLE_BG}

declare -r COLOR_INFO=${COLOR_CYAN}
declare -r COLOR_INFO_U=${COLOR_CYAN_U}
declare -r COLOR_INFO_B=${COLOR_CYAN_B}
declare -r COLOR_INFO_H=${COLOR_CYAN_H}
declare -r COLOR_INFO_I=${COLOR_CYAN_I}
declare -r COLOR_INFO_BG=${COLOR_CYAN_BG}

declare -r COLOR_QUESTION=${COLOR_YELLOW}
declare -r COLOR_QUESTION_U=${COLOR_YELLOW_U}
declare -r COLOR_QUESTION_B=${COLOR_YELLOW_B}
declare -r COLOR_QUESTION_H=${COLOR_YELLOW_H}
declare -r COLOR_QUESTION_I=${COLOR_YELLOW_I}
declare -r COLOR_QUESTION_BG=${COLOR_YELLOW_BG}

declare -r COLOR_NOTICE=${COLOR_BLUE}
declare -r COLOR_NOTICE_U=${COLOR_BLUE_U}
declare -r COLOR_NOTICE_B=${COLOR_BLUE_B}
declare -r COLOR_NOTICE_H=${COLOR_BLUE_H}
declare -r COLOR_NOTICE_I=${COLOR_BLUE_I}
declare -r COLOR_NOTICE_BG=${COLOR_BLUE_BG}

declare -r COLOR_SUCCESS=${COLOR_GREEN}
declare -r COLOR_SUCCESS_U=${COLOR_GREEN_U}
declare -r COLOR_SUCCESS_B=${COLOR_GREEN_B}
declare -r COLOR_SUCCESS_H=${COLOR_GREEN_H}
declare -r COLOR_SUCCESS_I=${COLOR_GREEN_I}
declare -r COLOR_SUCCESS_BG=${COLOR_GREEN_BG}

declare -r COLOR_ERROR=${COLOR_RED}
declare -r COLOR_ERROR_U=${COLOR_RED_U}
declare -r COLOR_ERROR_B=${COLOR_RED_B}
declare -r COLOR_ERROR_H=${COLOR_RED_H}
declare -r COLOR_ERROR_I=${COLOR_RED_I}
declare -r COLOR_ERROR_BG=${COLOR_RED_BG_I}

declare -r COLOR_CONSOLE="${COLOR_BLACK}${COLOR_CYAN_BG}"

# Lines
declare -r BOX_TL='\e(0\x6c\e(B' # ┌
declare -r BOX_BL='\e(0\x6d\e(B' # └
declare -r BOX_TR='\e(0\x6b\e(B' # ┐
declare -r BOX_BR='\e(0\x6a\e(B' # ┘
declare -r BOX_HB='\e(0\x77\e(B' # ┬
declare -r BOX_VR='\e(0\x74\e(B' # ├
declare -r BOX_VL='\e(0\x75\e(B' # ┤
declare -r BOX_HT='\e(0\x76\e(B' # ┴
declare -r BOX_X='\e(0\x6e\e(B'  # ┼
declare -r BOX_H='\e(0\x71\e(B'  # ─
declare -r BOX_V='\e(0\x78\e(B'  # │

# Icons
declare -r ICON_PARAGRAPH='¶'
declare -r ICON_QUOTATION='»'
declare -r ICON_INFO='☞'
declare -r ICON_SUCCESS='✓'
declare -r ICON_ERROR='✗'
declare -r ICON_PROMPT='↳'
declare -r ICON_COMMAND='$'
