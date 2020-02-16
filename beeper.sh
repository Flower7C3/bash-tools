#!/usr/bin/env bash

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

if hash 'beep' 2>/dev/null; then
    command_pattern_normal='beep -d %s -f %s'
    command_pattern_sustain='beep -d %s -f %s &'
    command_name='beep'
elif hash 'play' 2>/dev/null; then
    command_pattern_normal='play -q -n -c1 synth %s sine %s'
    command_pattern_sustain='play -q -n -c1 synth %s sine %s &'
    command_name='play'
else
    printf "Mucical command not found! Please install beep (apt install beep) or play (brew install sox).\n"
    exit 1
fi

function finish() {
    killall $command_name
    printf "Bye!\n\n"
}
trap finish EXIT

note_sustain='n'
note_tone_key=''
note_tone_name=''
note_tone_freq=''
note_octave=''
note_length_ms=''
note_length_sec=''
note_length_name=''
note_length_icon=''
verbose='1'
escape_char=$(printf "\u1b")

function reset_note() {
    note_sustain='n'
    note_tone_key=''
}
function set_note_sustain() {
    note_sustain='y'
}
function set_note_length() {
    local _note_length_ms="$1"
    if [[ "$_note_length_ms" -lt '100' ]]; then
        _note_length_ms='100'
    fi
    if [[ "$_note_length_ms" -gt '1600' ]]; then
        _note_length_ms='1600'
    fi
    note_length_ms="$_note_length_ms"
    note_length_sec=$(echo "scale=3; $note_length_ms/1000" | bc -l)
    case "$note_length_ms" in
    1600) note_length_name='WHOLE' ;;
    800 | $((note_length_ms > 800))*) note_length_name='HALF' ;;
    400 | $((note_length_ms > 400))*) note_length_name='QUARTER' ;;
    200 | $((note_length_ms > 200))*) note_length_name='EIGHTH' ;;
    100 | $((note_length_ms > 100))*) note_length_name='SIXTENNTH' ;;
    esac
    local _icon_key="MUSIC_NOTE_${note_length_name}"
    note_length_icon=${!_icon_key}
    if [[ "$verbose" -gt '0' ]]; then
        printf "Set note as %s $note_length_icon (%s ms)\n" "$note_length_name" "$note_length_ms"
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
        printf "Set octave as %s\n" "$note_octave"
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
    if [[ "$note_tone_key" == 'p' ]]; then
        play_pause
    else
        local _frequency_key="NOTE_${note_tone_key}_${note_octave}"
        note_tone_freq="${!_frequency_key}"
        play_note
    fi
}
function play_pause() {
    printf "$note_length_icon p (%s ms)" "$note_length_ms"
    sleep $note_length_sec
    printf "\n"
}
function play_note() {
    if [[ "$note_sustain" == 'y' ]]; then
        printf "$note_length_icon %s%s Led. (%s ms %s Hz)" "$note_tone_name" "$note_octave" "$note_length_ms" "$note_tone_freq"
        eval "$(printf "$command_pattern_sustain" "$note_length_sec" "$note_tone_freq")"
    else
        printf "$note_length_icon %s%s (%s ms %s Hz)" "$note_tone_name" "$note_octave" "$note_length_ms" "$note_tone_freq"
        eval "$(printf "$command_pattern_normal" "$note_length_sec" "$note_tone_freq")"
    fi
    printf "\n"
}
function main_loop() {
    # RESET
    reset_note
    local _octave_extra='n'
    # READ
    read -r -n 1 -p "$MUSIC_CLEF_G " key
    printf "\r$MUSIC_CLEF_G "
    if [[ $key == $escape_char ]]; then
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
    # NOTE LENGTH
    '[C')
        set_note_length $((note_length_ms + 100))
        ;;
    '[D')
        set_note_length $((note_length_ms - 100))
        ;;
    5) set_note_length 1600 ;;
    4) set_note_length 800 ;;
    3) set_note_length 400 ;;
    2) set_note_length 200 ;;
    1) set_note_length 100 ;;
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
    local notes_data=($(cat "$1" | grep -v '#'))
    verbose='0'
    local total=$((${#notes_data[@]} - 1))
    local i=0
    while true; do
        if [[ "$i" -gt "$total" ]]; then
            break
        fi
        reset_note
        note_data="${notes_data[$i]}"
        note_arr=($(echo "${note_data}" | sed 's/,/ /g'))
        note_tone_arr=($(echo "${note_arr[0]}" | sed 's/./& /g'))
        if [[ $(
            echo "$note_data" | grep -qE '^p'
            echo $?
        ) -eq "0" ]]; then
            set_note_length $(echo "${note_arr[1]} * 100" | bc)
            play_pause "$note_length_ms"
        else
            set_note_length $(echo "${note_arr[1]} * 100" | bc)
            set_note_tone "${note_tone_arr[0]}"
            set_note_octave "${note_tone_arr[1]}"
            if [[ -n "${note_arr[2]}" ]]; then
                set_note_sustain
            fi
            play_value
        fi
        i=$((i + 1))
    done
}

echo "Press [CTRL+C] to stop.."
set_note_length "200"
set_note_octave "4"
if [[ "$1" != "" ]] && [[ -f $1 ]]; then
    file_read "$1"
else
    while true; do
        main_loop
    done
fi
