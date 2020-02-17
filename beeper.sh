#!/usr/bin/env bash

### COLORS ###
declare -r COLOR_OFF='\033[0m'       # Text Reset
declare -r COLOR_RED='\033[0;31m'    # Red
declare -r COLOR_GREEN='\033[0;32m'  # Green
declare -r COLOR_YELLOW='\033[0;33m' # Yellow
declare -r COLOR_CYAN='\033[0;36m'   # Cyan
declare -r COLOR_WHITE='\033[0;37m'  # White
declare -r ICON_INFO='☞'
declare -r ICON_SUCCESS='✓'
declare -r ICON_ERROR='✗'
declare -r ICON_MESSAGE='✉'
declare -r ICON_PROMPT='↳'
declare -r DISPLAY_LINE_NO_ICON='display_line.no_icon'
declare -r DISPLAY_LINE_SILENT_BELL='display_line.silent_bell'
declare -r DISPLAY_LINE_PREPEND_NL='display_line.line_prepend_nl'
declare -r DISPLAY_LINE_PREPEND_CR='display_line.line_prepend_cr'
declare -r DISPLAY_LINE_PREPEND_TAB='display_line.line_prepend_tab'
declare -r DISPLAY_LINE_APPEND_NULL='display_line.line_append_null'
declare -r DISPLAY_LINE_APPEND_NL='display_line.line_append_nl'

### NOTES ###
# notes, see http://people.virginia.edu/~pdr4h/pitch-freq.html
NOTE_a_0=27.500
NOTE_A_0=29.135
NOTE_b_0=30.868
NOTE_c_1=32.703
NOTE_C_1=34.648
NOTE_d_1=36.708
NOTE_D_1=38.891
NOTE_e_1=41.203
NOTE_f_1=43.654
NOTE_F_1=46.249
NOTE_g_1=48.999
NOTE_G_1=51.913
NOTE_a_1=55.000
NOTE_A_1=58.270
NOTE_b_1=61.735
NOTE_c_2=65.406
NOTE_C_2=69.296
NOTE_d_2=73.416
NOTE_D_2=77.782
NOTE_e_2=82.407
NOTE_f_2=87.307
NOTE_F_2=92.499
NOTE_g_2=97.999
NOTE_G_2=103.826
NOTE_a_2=110.000
NOTE_A_2=116.541
NOTE_b_2=123.471
NOTE_c_3=130.813
NOTE_C_3=138.591
NOTE_d_3=146.832
NOTE_D_3=155.564
NOTE_e_3=164.814
NOTE_f_3=174.614
NOTE_F_3=184.997
NOTE_g_3=195.998
NOTE_G_3=207.652
NOTE_a_3=220.000
NOTE_A_3=233.082
NOTE_b_3=246.942
NOTE_c_4=261.626
NOTE_C_4=277.183
NOTE_d_4=293.665
NOTE_D_4=311.127
NOTE_e_4=329.628
NOTE_f_4=349.228
NOTE_F_4=369.994
NOTE_g_4=391.995
NOTE_G_4=415.305
NOTE_a_4=440.000
NOTE_A_4=466.164
NOTE_b_4=493.883
NOTE_c_5=523.251
NOTE_C_5=554.365
NOTE_d_5=587.330
NOTE_D_5=622.254
NOTE_e_5=659.255
NOTE_f_5=698.457
NOTE_F_5=739.989
NOTE_g_5=783.991
NOTE_G_5=830.609
NOTE_a_5=880.000
NOTE_A_5=932.328
NOTE_b_5=987.767
NOTE_c_6=1046.502
NOTE_C_6=1108.731
NOTE_d_6=1174.659
NOTE_D_6=1244.508
NOTE_e_6=1318.510
NOTE_f_6=1396.913
NOTE_F_6=1479.978
NOTE_g_6=1567.982
NOTE_G_6=1661.219
NOTE_a_6=1760.000
NOTE_A_6=1864.655
NOTE_b_6=1975.533
NOTE_c_7=2093.005
NOTE_C_7=2217.461
NOTE_d_7=2349.318
NOTE_D_7=2489.016
NOTE_e_7=2637.021
NOTE_f_7=2793.826
NOTE_F_7=2959.956
NOTE_g_7=3135.964
NOTE_G_7=3322.438
NOTE_a_7=3520.000
NOTE_A_7=3729.310
NOTE_b_7=3951.066
NOTE_c_8=4186.009
NOTE_C_8=4434.922
NOTE_d_8=4698.637
NOTE_D_8=4978.032
NOTE_e_8=5274.042
NOTE_f_8=5587.652
NOTE_F_8=5919.912
NOTE_g_8=6271.928
NOTE_G_8=6644.876
NOTE_a_8=7040.000
NOTE_A_8=7458.620
NOTE_b_8=7902.133
NOTE_c_9=8372.019
NOTE_C_9=8869.845
NOTE_d_9=9397.273
NOTE_D_9=9956.064
NOTE_e_9=10548.083
NOTE_f_9=11175.305
NOTE_F_9=11839.823
NOTE_g_9=12543.855
NOTE_G_9=13289.752
MUSIC_NOTE_WHOLE="\uF88C "
MUSIC_NOTE_HALF="\uF888 "
MUSIC_NOTE_QUARTER="\uF88A "
MUSIC_NOTE_EIGHTH="\uF887 "
MUSIC_NOTE_SIXTENNTH="\uF88B "
MUSIC_CLEF_G='𝄞'      # \xF0\x9D\x84\x9E
MUSIC_SIGN_FLAT='♭'    # \xe2\x99\xad
MUSIC_SIGN_NATURAL='♮' # \xe2\x99\xae
MUSIC_SIGN_SHARP='♯'   # \xe2\x99\xaf

### DISPLAY ###
function display_line() {
    local _color=$1
    shift
    local _icon="$1 "
    shift
    local _line_prepend=""
    local _line_append="\n"
    while true; do
        case $1 in
        $DISPLAY_LINE_NO_ICON)
            _icon=""
            ;;
        $DISPLAY_LINE_SILENT_BELL)
            _line_prepend="\eg\a\r"
            ;;
        $DISPLAY_LINE_PREPEND_NL)
            _line_prepend="\n"
            ;;
        $DISPLAY_LINE_PREPEND_CR)
            _line_prepend="\r"
            ;;
        $DISPLAY_LINE_PREPEND_TAB)
            _line_prepend="\t"
            ;;
        $DISPLAY_LINE_APPEND_NL)
            _line_append="\n"
            ;;
        $DISPLAY_LINE_APPEND_NULL)
            _line_append=""
            ;;
        *)
            break
            ;;
        esac
        shift
    done
    local _text_pattern="$1"
    shift
    local _text
    _text=$(printf "$_text_pattern" "$@")
    echo -e -n "${_line_prepend}${_color}${_icon}${_text}${COLOR_OFF}${_line_append}"
}
function display_info() {
    display_line "$COLOR_CYAN" "$ICON_INFO" "$@"
}
function display_message() {
    display_line "$COLOR_WHITE" "$ICON_MESSAGE" "$@"
}
function display_success() {
    display_line "$COLOR_GREEN" "$ICON_SUCCESS" "$@"
}
function display_error() {
    display_line "$COLOR_RED" "$ICON_ERROR" "$@"
}

### CONFIG ###
command_pattern_normal=''
command_pattern_sustain=''
time_mode=''
command_name=''
notes_file_name=''
note_sustain='n'
note_tone_key=''
note_tone_name=''
note_tone_freq=''
note_octave=''
note_type_id=''
note_type_icon=''
note_speed=''
note_length_ms=''
note_length_sec=''
verbose='1'

### BEEPER ###
function reset_note() {
    note_sustain='n'
    note_tone_key=''
}
function set_note_sustain() {
    note_sustain='y'
}
function set_note_type() {
    local _note_type_id="$1"
    if [[ "$_note_type_id" -lt '1' ]]; then
        _note_type_id='1'
    fi
    if [[ "$_note_type_id" -gt '16' ]]; then
        _note_type_id='16'
    fi
    note_type_id="$_note_type_id"
    local _note_length_name
    case "$note_type_id" in
    16) _note_length_name='WHOLE' ;;
    8 | $((note_type_id > 8))*) _note_length_name='HALF' ;;
    4 | $((note_type_id > 4))*) _note_length_name='QUARTER' ;;
    2 | $((note_type_id > 2))*) _note_length_name='EIGHTH' ;;
    1 | $((note_type_id > 1))*) _note_length_name='SIXTENNTH' ;;
    esac
    local _icon_key="MUSIC_NOTE_${_note_length_name}"
    note_type_icon=${!_icon_key}
    if [[ "$verbose" -gt '0' ]]; then
        display_info "Set note type as %s $note_type_icon\n" "$_note_length_name"
    fi
}
function set_note_speed() {
    local _speed="$1"
    if [[ "$_speed" -lt '30' ]]; then
        _speed='30'
    fi
    if [[ "$_speed" -gt '200' ]]; then
        _speed='200'
    fi
    note_speed="$_speed"
    if [[ "$verbose" -gt '0' ]]; then
        display_info "Set speed as %s\n" "$note_speed"
    fi
}
function set_note_octave() {
    local _note_octave="$1"
    if [[ "$_note_octave" -lt '1' ]]; then
        _note_octave='1'
    fi
    if [[ "$_note_octave" -gt '8' ]]; then
        _note_octave='8'
    fi
    note_octave="$_note_octave"
    if [[ "$verbose" -gt '0' ]]; then
        display_info "Set octave as %s\n" "$note_octave"
    fi
}
function set_note_tone() {
    local _tone_key="$1"
    note_tone_key="$_tone_key"
    note_tone_name=${note_tone_key^^}
    case $note_tone_key in
    C | D | F | G | A) note_tone_name="${note_tone_key}${MUSIC_SIGN_SHARP}" ;;
    esac
}
function play_value() {
    note_length_ms=$(echo "$note_type_id * 15000/$note_speed" | bc)
    note_length_sec=$(echo "scale=3; $note_length_ms/1000" | bc -l)
    if [[ "$note_tone_key" == 'p' ]]; then
        play_pause
    else
        local _frequency_key="NOTE_${note_tone_key}_${note_octave}"
        note_tone_freq="${!_frequency_key}"
        play_note
    fi
}
function play_pause() {
    printf "$note_type_icon p (%s ms)" "$note_length_ms"
    sleep "$note_length_sec"
    printf "\n"
}
function play_note() {
    local _time="0"
    if [[ "$time_mode" == "ms" ]]; then
        _time="$note_length_ms"
    elif [[ "$time_mode" == "sec" ]]; then
        _time="$note_length_sec"
    fi
    if [[ "$note_sustain" == 'y' ]]; then
        printf "$note_type_icon %s%s Led. (%s ms %s Hz)" "$note_tone_name" "$note_octave" "$note_length_ms" "$note_tone_freq"
        eval "$(printf "$command_pattern_sustain" "$_time" "$note_tone_freq")"
    else
        printf "$note_type_icon %s%s (%s ms %s Hz)" "$note_tone_name" "$note_octave" "$note_length_ms" "$note_tone_freq"
        eval "$(printf "$command_pattern_normal" "$_time" "$note_tone_freq")"
    fi
    printf "\n"
}
function main_loop() {
    # RESET
    reset_note
    local _octave_extra='n'
    local _escape_char
    _escape_char=$(printf "\u1b")
    # READ
    read -r -n 1 -p "$MUSIC_CLEF_G " key
    printf "\r$MUSIC_CLEF_G "
    if [[ $key == "$_escape_char" ]]; then
        read -rsn2 key # read 2 more chars
    fi
    # octave extra
    if [[ "$key" == ',' ]] || [[ "$key" == '<' ]]; then
        _octave_extra='y'
    fi

    if [[ "$_octave_extra" == 'y' ]]; then
        note_octave=$((note_octave + 1))
    fi

    case "$key" in
    # NOTE SPEED
    '[C')
        set_note_speed $((note_speed + 5))
        ;;
    '[D')
        set_note_speed $((note_speed - 5))
        ;;
    # NOTE TYPE
    1) set_note_type 16 ;;
    2) set_note_type 8 ;;
    3) set_note_type 4 ;;
    4) set_note_type 2 ;;
    5) set_note_type 1 ;;
    '[A')
        set_note_octave $((note_octave + 1))
        ;;
    '[B')
        set_note_octave $((note_octave - 1))
        ;;
    # NOTE TONE
    \`) set_note_tone 'p' ;;
    z | Z) set_note_tone 'c' ;;
    s | S) set_note_tone 'C' ;;
    x | X) set_note_tone 'd' ;;
    d | D) set_note_tone 'D' ;;
    c | C) set_note_tone 'e' ;;
    v | V) set_note_tone 'f' ;;
    g | G) set_note_tone 'F' ;;
    b | B) set_note_tone 'g' ;;
    h | H) set_note_tone 'G' ;;
    n | N) set_note_tone 'a' ;;
    j | J) set_note_tone 'A' ;;
    m | M) set_note_tone 'b' ;;
    , | \<) set_note_tone 'c' ;;
    *) printf " \r" ;;
    esac
    # SUSTAIN
    case "$key" in
    Z | S | X | D | C | V | G | B | H | N | J | M | \<)
        set_note_sustain
        ;;
    esac
    # PLAY
    if [[ "$note_tone_key" != '' ]]; then
        play_value
    fi
    if [[ "$_octave_extra" == 'y' ]]; then
        note_octave=$((note_octave - 1))
    fi
}
function file_read() {
    local _notes_data=($(cat "$notes_file_name" | grep -v '#'))
    verbose='0'
    local _total=$((${#_notes_data[@]} - 1))
    local _i=0
    while true; do
        if [[ "$_i" -gt "$_total" ]]; then
            break
        fi
        reset_note
        local _note_data
        _note_data="${_notes_data[$_i]}"
        local _note_arr
        _note_arr=($(echo "${_note_data}" | sed 's/,/ /g'))
        local _note_tone_arr
        _note_tone_arr=($(echo "${_note_arr[0]}" | sed 's/./& /g'))
        if [[ $(
            echo "$_note_data" | grep -qE '^p'
            echo $?
        ) -eq "0" ]]; then
            set_note_type "${_note_arr[1]}"
            play_pause "$note_length_ms"
        else
            set_note_type "${_note_arr[1]}"
            set_note_tone "${_note_tone_arr[0]}"
            set_note_octave "${_note_tone_arr[1]}"
            if [[ -n "${_note_arr[2]}" ]]; then
                set_note_sustain
            fi
            play_value
        fi
        _i=$((_i + 1))
    done
}
function config_load() {
    if hash 'beep' 2>/dev/null; then
        command_pattern_normal='beep -l %s -f %s'
        command_pattern_sustain='beep -l %s -f %s &'
        time_mode='ms'
        command_name='beep'
    elif hash 'play' 2>/dev/null; then
        command_pattern_normal='play -q -n -c1 synth %s sine %s'
        command_pattern_sustain='play -q -n -c1 synth %s sine %s &'
        time_mode='sec'
        command_name='play'
    else
        display_error "Mucical command not found! Please install beep (apt install beep) or play (brew install sox)."
        exit 1
    fi
    local _note_type="4"
    local _note_speed="120"
    local _note_octave="4"
    while [[ "$1" != "" ]]; do
        case ${1} in
        -h | --help)
            display_info "$0 [-t <int>] [-s <int>] [-o <int>] [-f <path>]"
            display_info "$DISPLAY_LINE_PREPEND_TAB" "$DISPLAY_LINE_NO_ICON" "%s\t%s" "-t|--type - note type; integer; 16=whole, 8=half, 4=quarter, 2=eighth, 1=sixtennth"
            display_info "$DISPLAY_LINE_PREPEND_TAB" "$DISPLAY_LINE_NO_ICON" "%s\t%s" "-s|--speed - note speed; integer; from 30 to 200"
            display_info "$DISPLAY_LINE_PREPEND_TAB" "$DISPLAY_LINE_NO_ICON" "%s\t%s" "-o|--octave - note octave; integer; from 1 to 8"
            display_info "$DISPLAY_LINE_PREPEND_TAB" "$DISPLAY_LINE_NO_ICON" "%s\t%s" "-f|--file - filepath of tabs"
            display_info "$DISPLAY_LINE_PREPEND_TAB" "$DISPLAY_LINE_NO_ICON" "%s\t%s" "-u|--update - update app"
            exit 0
            ;;
        -u | --update)
            display_info "Downloading new app version"
            curl "https://raw.githubusercontent.com/Flower7C3/bash-tools/master/beeper.sh" >$0
            exit
            ;;
        -t | --type)
            shift
            _note_type="$1"
            ;;
        -s | --speed)
            shift
            _note_speed="$1"
            ;;
        -o | --octave)
            shift
            _note_octave="$1"
            ;;
        -f | --file)
            shift
            notes_file_name="$1"
            ;;
        esac
        shift
    done
    set_note_type "$_note_type"
    set_note_speed "$_note_speed"
    set_note_octave "$_note_octave"
}
### TRAP ###
function finish() {
    killall $command_name
}
trap finish EXIT

### MAIN ###
display_message "Press [CTRL+C] to stop.."
config_load "$@"
if [[ "$notes_file_name" != "" ]] && [[ -f $notes_file_name ]]; then
    file_read
else
    while true; do
        main_loop
    done
fi
