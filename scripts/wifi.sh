#!/usr/bin/env bash

# Starts a scan of available broadcasting SSIDs
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FIELDS=SSID,SECURITY,BSSID,SIGNAL
POSITION=0
YOFF=0
XOFF=0

if [ -r "$DIR/config" ]; then
    source "$DIR/config"
elif [ -r "$HOME/.config/wofi/wifi" ]; then
    source "$HOME/.config/wofi/wifi"
else
    echo "WARNING: config file not found! Using default values."
fi

# Function to refresh wifi list
refresh_wifi_list() {
    echo "Scanning for WiFi networks..."
    # Force rescan and wait for results
    nmcli dev wifi rescan
    sleep 2
}

# Refresh wifi list before displaying
refresh_wifi_list

# Get wifi list with more fields and better formatting
LIST=$(nmcli --fields "$FIELDS" device wifi list --rescan yes 2>/dev/null | sed '/^--/d')
if [ -z "$LIST" ]; then
    # If list is empty, try one more time with rescan
    refresh_wifi_list
    LIST=$(nmcli --fields "$FIELDS" device wifi list 2>/dev/null | sed '/^--/d')
fi

# Debug: Save list to file for inspection
echo "$LIST" >/tmp/wifi_list_debug.txt

# Remove duplicate BSSIDs and keep the strongest signal
LIST=$(echo "$LIST" | awk '
{
    # Extract BSSID (assuming it is the third field)
    bssid = $3
    signal = $4
    # Store the line with the strongest signal for each BSSID
    if (!(bssid in best) || signal > best_signal[bssid]) {
        best[bssid] = $0
        best_signal[bssid] = signal
    }
}
END {
    for (bssid in best) {
        print best[bssid]
    }
}' | sort -k4,4nr) # Sort by signal strength

# For some reason wofi always approximates character width 2 short... hmmm
RWIDTH=$(($(echo "$LIST" | head -n 1 | awk '{print length($0); }') * 10))
# Dynamically change the height of the wofi menu
LINENUM=$(echo "$LIST" | wc -l)

# Gives a list of known connections so we can parse it later
KNOWNCON=$(nmcli connection show)
# Really janky way of telling if there is currently a connection
CONSTATE=$(nmcli -fields WIFI g)

CURRSSID=$(LANGUAGE=C nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')

if [[ ! -z $CURRSSID ]]; then
    HIGHLINE=$(echo "$(echo "$LIST" | awk -F "[  ]{2,}" '{print $1}' | grep -Fxn -m 1 "$CURRSSID" | awk -F ":" '{print $1}') + 1" | bc)
fi

# HOPEFULLY you won't need this as often as I do
# If there are more than 8 SSIDs, the menu will still only have 8 lines
if [ "$LINENUM" -gt 8 ] && [[ "$CONSTATE" =~ "enabled" ]]; then
    LINENUM=8
elif [[ "$CONSTATE" =~ "disabled" ]]; then
    LINENUM=1
fi

if [[ "$CONSTATE" =~ "enabled" ]]; then
    TOGGLE="toggle off"
elif [[ "$CONSTATE" =~ "disabled" ]]; then
    TOGGLE="toggle on"
fi

# Display available networks with signal strength
echo -e "Available WiFi Networks:\n$LIST"
CHENTRY=$(echo -e "$TOGGLE\nmanual\n$LIST" | uniq -u | wofi -i -d --prompt "Wi-Fi SSID: " --lines "$LINENUM" --width 600)
CHSSID=$(echo "$CHENTRY" | sed 's/\s\{2,\}/\|/g' | awk -F "|" '{print $1}')

# If the user inputs "manual" as their SSID in the start window, it will bring them to this screen
if [ "$CHENTRY" = "manual" ]; then
    # Manual entry of the SSID and password (if applicable)
    MSSID=$(echo "enter the SSID of the network (SSID,password)" | wofi -d --prompt "Manual Entry: " --lines 1)
    # Separating the password from the entered string
    MPASS=$(echo "$MSSID" | awk -F "," '{print $2}')
    MSSID=$(echo "$MSSID" | awk -F "," '{print $1}')

    # If the user entered a manual password, then use the password nmcli command
    if [ "$MPASS" = "" ]; then
        nmcli dev wifi con "$MSSID"
    else
        nmcli dev wifi con "$MSSID" password "$MPASS"
    fi

elif [ "$CHENTRY" = "toggle on" ]; then
    nmcli radio wifi on

elif [ "$CHENTRY" = "toggle off" ]; then
    nmcli radio wifi off

else

    # If the connection is already in use, then this will still be able to get the SSID
    if [ "$CHSSID" = "*" ]; then
        CHSSID=$(echo "$CHENTRY" | sed 's/\s\{2,\}/\|/g' | awk -F "|" '{print $3}')
    fi

    # Clean SSID - remove extra spaces
    CHSSID=$(echo "$CHSSID" | sed 's/^[ \t]*//;s/[ \t]*$//')

    # Parses the list of preconfigured connections to see if it already contains the chosen SSID. This speeds up the connection process
    if [[ $(echo "$KNOWNCON" | grep -w "$CHSSID") ]]; then
        nmcli con up "$CHSSID"
    else
        # Get security type from the selected entry
        SECURITY=$(echo "$CHENTRY" | sed 's/\s\{2,\}/\|/g' | awk -F "|" '{print $2}')

        if [[ "$SECURITY" =~ "WPA2" ]] || [[ "$SECURITY" =~ "WPA3" ]] || [[ "$SECURITY" =~ "WEP" ]]; then
            WIFIPASS=$(echo "Enter password for $CHSSID" | wofi -d --prompt "Password: " --lines 1 --password)
            if [ -n "$WIFIPASS" ]; then
                nmcli dev wifi con "$CHSSID" password "$WIFIPASS"
            else
                echo "Error: Password required for secured network"
                notify-send "WiFi Connection" "Password required for $CHSSID"
                exit 1
            fi
        elif [[ "$SECURITY" == "--" ]] || [[ -z "$SECURITY" ]]; then
            # Open network - no password needed
            nmcli dev wifi con "$CHSSID"
        else
            # For other security types, try with password prompt
            WIFIPASS=$(echo "Enter password for $CHSSID (security: $SECURITY)" | wofi -d --prompt "Password: " --lines 1 --password)
            if [ -n "$WIFIPASS" ]; then
                nmcli dev wifi con "$CHSSID" password "$WIFIPASS"
            else
                nmcli dev wifi con "$CHSSID"
            fi
        fi
    fi

fi
