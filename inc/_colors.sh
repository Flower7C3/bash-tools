# https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
# https://stackoverflow.com/a/26665998/2910183
function rgb_to_ansi256 {
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
		    ansi=$(( ((($r - 8) / 247) * 24) + 232 ))
	    fi
    else
	    local r_index=$(( (36 * ($r / 255 * 5)) ))
	    local g_index=$(( (6 * ($g / 255 * 5)) ))
	    local b_index=$(( ($b / 255 * 5) ))
	    ansi=$(( 16 + $r_index + $g_index + $b_index ))
    fi
	printf ${ansi%.*}
}

function rgb_foreground {
	local r=$1
	local g=$2
	local b=$3
	local code=$(rgb_to_ansi256 $r $g $b)
	printf "\033[38;5;%sm" "$code"
}

function rgb_background {
	local r=$1
	local g=$2
	local b=$3
	local code=$(rgb_to_ansi256 $r $g $b)
	printf "\033[48;5;%sm" "$code"
}

# Reset
color_off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White



# Events

color_default=${White}
color_default_u=${UWhite}
color_default_b=${BWhite}
color_default_h=${BIWhite}
color_default_i=${IWhite}
color_default_g=${On_White}

color_log=${Purple}
color_log_u=${UPurple}
color_log_b=${BPurple}
color_log_h=${BIPurple}
color_log_i=${IPurple}
color_log_g=${On_Purple}

color_info=${Cyan}
color_info_u=${UCyan}
color_info_b=${BCyan}
color_info_h=${BICyan}
color_info_i=${ICyan}
color_info_g=${On_Cyan}

color_question=${Yellow}
color_question_u=${UYellow}
color_question_b=${BYellow}
color_question_h=${BIYellow}
color_question_i=${IYellow}
color_question_g=${On_Yellow}

color_notice=${Blue}
color_notice_u=${UBlue}
color_notice_b=${BBlue}
color_notice_h=${BIBlue}
color_notice_i=${IBlue}
color_notice_g=${On_Blue}

color_success=${Green}
color_success_u=${UGreen}
color_success_b=${BGreen}
color_success_h=${BIGreen}
color_success_i=${IGreen}
color_success_g=${On_Green}

color_error=${Red}
color_error_u=${URed}
color_error_b=${BRed}
color_error_h=${BIRed}
color_error_i=${IRed}
color_error_g=${On_IRed}

color_console="${Black}${On_Cyan}"


# Lines

box_tl='\e(0\x6c\e(B' # ┌
box_bl='\e(0\x6d\e(B' # └
box_tr='\e(0\x6b\e(B' # ┐
box_br='\e(0\x6a\e(B' # ┘
box_hb='\e(0\x77\e(B' # ┬
box_vr='\e(0\x74\e(B' # ├
box_vl='\e(0\x75\e(B' # ┤
box_ht='\e(0\x76\e(B' # ┴
box_x='\e(0\x6e\e(B' # ┼
box_h='\e(0\x71\e(B' # ─
box_v='\e(0\x78\e(B' # │

icon_white_right_pointing_index='\xE2\x98\x9E'
icon_lower_right_pencil='\xE2\x9C\x8E'
icon_enter='\xe2\x86\xb3'
icon_zigzag='\xe2\x86\xaf'
icon_warning_sign='\xE2\x9A\xA0'
icon_position_indicator='\xE2\x8C\x96'
icon_check='\xE2\x9C\x93'
icon_command='$'