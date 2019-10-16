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
declare -r color_off='\033[0m'      # Text Reset

# Regular Colors
declare -r Black='\033[0;30m'       # Black
declare -r Red='\033[0;31m'         # Red
declare -r Green='\033[0;32m'       # Green
declare -r Yellow='\033[0;33m'      # Yellow
declare -r Blue='\033[0;34m'        # Blue
declare -r Purple='\033[0;35m'      # Purple
declare -r Cyan='\033[0;36m'        # Cyan
declare -r White='\033[0;37m'       # White

# Bold
declare -r BBlack='\033[1;30m'      # Black
declare -r BRed='\033[1;31m'        # Red
declare -r BGreen='\033[1;32m'      # Green
declare -r BYellow='\033[1;33m'     # Yellow
declare -r BBlue='\033[1;34m'       # Blue
declare -r BPurple='\033[1;35m'     # Purple
declare -r BCyan='\033[1;36m'       # Cyan
declare -r BWhite='\033[1;37m'      # White

# Underline
declare -r UBlack='\033[4;30m'      # Black
declare -r URed='\033[4;31m'        # Red
declare -r UGreen='\033[4;32m'      # Green
declare -r UYellow='\033[4;33m'     # Yellow
declare -r UBlue='\033[4;34m'       # Blue
declare -r UPurple='\033[4;35m'     # Purple
declare -r UCyan='\033[4;36m'       # Cyan
declare -r UWhite='\033[4;37m'      # White

# Background
declare -r On_Black='\033[40m'      # Black
declare -r On_Red='\033[41m'        # Red
declare -r On_Green='\033[42m'      # Green
declare -r On_Yellow='\033[43m'     # Yellow
declare -r On_Blue='\033[44m'       # Blue
declare -r On_Purple='\033[45m'     # Purple
declare -r On_Cyan='\033[46m'       # Cyan
declare -r On_White='\033[47m'      # White

# High Intensity
declare -r IBlack='\033[0;90m'      # Black
declare -r IRed='\033[0;91m'        # Red
declare -r IGreen='\033[0;92m'      # Green
declare -r IYellow='\033[0;93m'     # Yellow
declare -r IBlue='\033[0;94m'       # Blue
declare -r IPurple='\033[0;95m'     # Purple
declare -r ICyan='\033[0;96m'       # Cyan
declare -r IWhite='\033[0;97m'      # White

# Bold High Intensity
declare -r BIBlack='\033[1;90m'     # Black
declare -r BIRed='\033[1;91m'       # Red
declare -r BIGreen='\033[1;92m'     # Green
declare -r BIYellow='\033[1;93m'    # Yellow
declare -r BIBlue='\033[1;94m'      # Blue
declare -r BIPurple='\033[1;95m'    # Purple
declare -r BICyan='\033[1;96m'      # Cyan
declare -r BIWhite='\033[1;97m'     # White

# High Intensity backgrounds
declare -r On_IBlack='\033[0;100m'  # Black
declare -r On_IRed='\033[0;101m'    # Red
declare -r On_IGreen='\033[0;102m'  # Green
declare -r On_IYellow='\033[0;103m' # Yellow
declare -r On_IBlue='\033[0;104m'   # Blue
declare -r On_IPurple='\033[0;105m' # Purple
declare -r On_ICyan='\033[0;106m'   # Cyan
declare -r On_IWhite='\033[0;107m'  # White

# Events

declare -r color_default=${White}
declare -r color_default_u=${UWhite}
declare -r color_default_b=${BWhite}
declare -r color_default_h=${BIWhite}
declare -r color_default_i=${IWhite}
declare -r color_default_g=${On_White}

declare -r color_log=${Purple}
declare -r color_log_u=${UPurple}
declare -r color_log_b=${BPurple}
declare -r color_log_h=${BIPurple}
declare -r color_log_i=${IPurple}
declare -r color_log_g=${On_Purple}

declare -r color_info=${Cyan}
declare -r color_info_u=${UCyan}
declare -r color_info_b=${BCyan}
declare -r color_info_h=${BICyan}
declare -r color_info_i=${ICyan}
declare -r color_info_g=${On_Cyan}

declare -r color_question=${Yellow}
declare -r color_question_u=${UYellow}
declare -r color_question_b=${BYellow}
declare -r color_question_h=${BIYellow}
declare -r color_question_i=${IYellow}
declare -r color_question_g=${On_Yellow}

declare -r color_notice=${Blue}
declare -r color_notice_u=${UBlue}
declare -r color_notice_b=${BBlue}
declare -r color_notice_h=${BIBlue}
declare -r color_notice_i=${IBlue}
declare -r color_notice_g=${On_Blue}

declare -r color_success=${Green}
declare -r color_success_u=${UGreen}
declare -r color_success_b=${BGreen}
declare -r color_success_h=${BIGreen}
declare -r color_success_i=${IGreen}
declare -r color_success_g=${On_Green}

declare -r color_error=${Red}
declare -r color_error_u=${URed}
declare -r color_error_b=${BRed}
declare -r color_error_h=${BIRed}
declare -r color_error_i=${IRed}
declare -r color_error_g=${On_IRed}

declare -r color_console="${Black}${On_Cyan}"

# Lines

declare -r box_tl='\e(0\x6c\e(B'                          # ┌
declare -r box_bl='\e(0\x6d\e(B'                          # └
declare -r box_tr='\e(0\x6b\e(B'                          # ┐
declare -r box_br='\e(0\x6a\e(B'                          # ┘
declare -r box_hb='\e(0\x77\e(B'                          # ┬
declare -r box_vr='\e(0\x74\e(B'                          # ├
declare -r box_vl='\e(0\x75\e(B'                          # ┤
declare -r box_ht='\e(0\x76\e(B'                          # ┴
declare -r box_x='\e(0\x6e\e(B'                           # ┼
declare -r box_h='\e(0\x71\e(B'                           # ─
declare -r box_v='\e(0\x78\e(B'                           # │

declare -r icon_paragraph='¶'
declare -r icon_quotation='»'
declare -r icon_info='☞'
declare -r icon_success='✓'
declare -r icon_error='✗'
declare -r icon_prompt='↳'
declare -r icon_command='$'
