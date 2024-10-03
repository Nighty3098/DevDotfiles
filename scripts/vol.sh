#!/bin/bash

# See README.md for usage instructions
volume_step=5
brightness_step=5
max_volume=100
notification_timeout=1000
download_album_art=true
show_album_art=true
show_music_in_volume_indicator=true

# Uses regex to get volume from pactl
function get_volume {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -1
}

# Uses regex to get mute status from pactl
function get_mute {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: )(yes|no)'
}

# Uses regex to get brightness from xbacklight
function get_brightness {
    sudo light | grep -Po '[0-9]{1,3}' | head -n 1
}

# Returns a mute icon, a volume-low icon, or a volume-high icon, depending on the volume
function get_volume_icon {
    volume=$(get_volume)
    mute=$(get_mute)
    if [ "$volume" -eq 0 ] || [ "$mute" == "yes" ] ; then
        volume_icon="   "
    elif [ "$volume" -lt 50 ]; then
        volume_icon="   "
    else
        volume_icon="   "
    fi
}

# Always returns the same icon - I couldn't get the brightness-low icon to work with fontawesome
function get_brightness_icon {
    brightness_icon=""
}

function get_album_art {
    url=$(playerctl -f "{{mpris:artUrl}}" metadata)
    if [[ $url == "file://"* ]]; then
        album_art="${url/file:\/\//}"
    elif [[ $url == "http://"* ]] && [[ $download_album_art == "true" ]]; then
        # Identify filename from URL
        filename="$(echo $url | sed "s/.*\///")"

        # Download file to /tmp if it doesn't exist
        if [ ! -f "/tmp/$filename" ]; then
            wget -O "/tmp/$filename" "$url"
        fi

        album_art="/tmp/$filename"
    elif [[ $url == "https://"* ]] && [[ $download_album_art == "true" ]]; then
        # Identify filename from URL
        filename="$(echo $url | sed "s/.*\///")"

        # Download file to /tmp if it doesn't exist
        if [ ! -f "/tmp/$filename" ]; then
            wget -O "/tmp/$filename" "$url"
        fi

        album_art="/tmp/$filename"
    else
        album_art=""
    fi
}

# Displays a volume notification
function show_volume_notif {
    volume=$(get_mute)
    get_volume_icon

    if [[ $show_music_in_volume_indicator == "true" ]]; then
        current_song=$(playerctl -f "{{title}} - {{artist}}" metadata)

        if [[ $show_album_art == "true" ]]; then
            get_album_art
        fi

        notify-send -t $notification_timeout -h string:x-dunst-stack-tag:volume_notif -h int:value:$volume -i "$album_art" "$volume_icon $volume%" "$current_song"
    else
        notify-send -t $notification_timeout -h string:x-dunst-stack-tag:volume_notif -h int:value:$volume "$volume_icon $volume%"
    fi
}

# Displays a music notification
function show_music_notif {
    song_title=$(playerctl -f "{{title}}" metadata)
    song_artist=$(playerctl -f "{{artist}}" metadata)
    song_album=$(playerctl -f "{{album}}" metadata)

    if [[ $show_album_art == "true" ]]; then
        get_album_art
    fi

    notify-send -t $notification_timeout -h string:x-dunst-stack-tag:music_notif -i "$album_art" "$song_title" "$song_artist - $song_album"
}

# Displays a brightness notification using dunstify
function show_brightness_notif {
    brightness=$(get_brightness)
    echo $brightness
    get_brightness_icon
    notify-send -t $notification_timeout -h string:x-dunst-stack-tag:brightness_notif -h int:value:$brightness "$brightness_icon $brightness%"
}

# Main function - Takes user input, "volume_up", "volume_down", "brightness_up", or "brightness_down"
case $1 in
    volume_up)
    # Unmutes and increases volume, then displays the notification
    pactl set-sink-mute @DEFAULT_SINK@ 0
    volume=$(get_volume)
    if [ $(( "$volume" + "$volume_step" )) -gt $max_volume ]; then
        pactl set-sink-volume @DEFAULT_SINK@ $max_volume%
    else
        pactl set-sink-volume @DEFAULT_SINK@ +$volume_step%
    fi
    show_volume_notif
    ;;

    volume_down)
    # Raises volume and displays the notification
    pactl set-sink-volume @DEFAULT_SINK@ -$volume_step%
    show_volume_notif
    ;;

    volume_mute)
    # Toggles mute and displays the notification
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    show_volume_notif
    ;;

    brightness_up)
    # Increases brightness and displays the notification
    sudo light -A $brightness_step
    show_brightness_notif
    ;;

    brightness_down)
    # Decreases brightness and displays the notification
    sudo light -U $brightness_step
    show_brightness_notif
    ;;

    next_track)
    # Skips to the next song and displays the notification
    playerctl next
    sleep 0.5 && show_music_notif
    ;;

    prev_track)
    # Skips to the previous song and displays the notification
    playerctl previous
    sleep 0.5 && show_music_notif
    ;;

    play_pause)
    playerctl play-pause
    show_music_notif
    # Pauses/resumes playback and displays the notification
    ;;
esac
