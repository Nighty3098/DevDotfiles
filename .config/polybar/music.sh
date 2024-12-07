#!/bin/sh

truncate_string() {
    local input_string="$1"
    echo "${input_string:0:35}..."
}

function get_current_song() {
    players=(
        "amarok"
        "audacious"
        "banshee"
        "clementine"
        "cmus"
        "deadbeef"
        "vlc"
        "spotify"
        "rhythmbox"
        "playerctl"
        "mpd"
        "mopidy"
    )

    printf -v players_pattern "|%s" "${players[@]}"
    player="$(ps aux | awk -v pattern="(${players_pattern:1})" \
        '!/ awk / && match($0, pattern) {print substr($0, RSTART, RLENGTH); exit}')"

    get_song_dbus() {
        song="$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2."${1}" /org/mpris/MediaPlayer2 \
            org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' \
            string:'Metadata' |\
            awk -F '"' 'BEGIN {RS=" entry"}; /"xesam:artist"/ {a = $4} /"xesam:album"/ {b = $4}
                        /"xesam:title"/ {t = $4} END {print a " \n" b " \n" t}')"
    }

    case ${player/*\/} in
        "vlc"*)           song="$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 \
                            org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' \
                            string:'Metadata' | awk -F '"' '/"xesam:artist"/ {print $4} /"xesam:title"/ {print $4}')" ;;
        "spotify"*)       song="$(playerctl metadata --format '{{ artist }} \n{{ album }} \n{{ title }}')" ;;
        "rhythmbox"*)     get_song_dbus "rhythmbox" ;;
        "mpd"*)           song="$(mpc -f '%artist% \n%album% \n%title%' current)" ;;
        "mopidy"*)        song="$(mpc -f '%artist% \n%album% \n%title%' current)" ;;
        *)                echo -e "${BLUE}${MUSIC} " && return ;;
    esac

    IFS=$'\n' read -d "" artist album title <<< "${song//'\n'/$'\n'}"

    artist="${artist:-Unknown Artist}"
    album="${album:-Unknown Album}"
    title="${title:-Unknown Song}"

    truncate_string "  ${artist} - ${title}"
}

get_current_song
