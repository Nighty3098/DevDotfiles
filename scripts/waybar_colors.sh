#!/bin/bash

PYWAL_COLORS="$HOME/.cache/wal/colors.json"
WAYBAR_CSS="$HOME/.config/waybar/style.css"
DEFAULT_BG="#141415"
DEFAULT_BG_ALT="#252530"
DEFAULT_COLOR="#cdcdcd"
DEFAULT_HOVER_BG="#cdd6f4"
DEFAULT_HOVER_COLOR="#606079"
DEFAULT_ACTIVE_BG="#606079"
DEFAULT_URGENT_COLOR="#f38ba8"
DEFAULT_PLAYING_COLOR="#a6e3a1"
DEFAULT_PAUSED_COLOR="#9399b2"
DEFAULT_CPU_COLOR="#8ba9c1"
DEFAULT_MEMORY_COLOR="#7fa563"
DEFAULT_LANGUAGE_COLOR="#bb9dbd"
DEFAULT_WINDOW_COLOR="#aeaed1"
DEFAULT_PULSEAUDIO_COLOR="#6e94b2"
DEFAULT_PULSEAUDIO_MUTED_COLOR="#f3be7c"
DEFAULT_CUSTOM_POWER_COLOR="#d8647e"
DEFAULT_TOOLTIP_BORDER="#606079"

get_json_value() {
    echo "$1" | grep -oP '"'"$2"'": *"\K[^"]*'
}

# Чтение цветов из Pywal
if [ -f "$PYWAL_COLORS" ]; then
    COLORS_JSON=$(cat "$PYWAL_COLORS")

    BG_COLOR=$(get_json_value "$COLORS_JSON" background)
    BG_ALT_COLOR=$(get_json_value "$COLORS_JSON" color1)
    FG_COLOR=$(get_json_value "$COLORS_JSON" foreground)
    COLOR_HOVER=$(get_json_value "$COLORS_JSON" color4)
    COLOR_ACTIVE=$(get_json_value "$COLORS_JSON" color6)
    COLOR_URGENT=$(get_json_value "$COLORS_JSON" color9)
    COLOR_PLAYING=$(get_json_value "$COLORS_JSON" color10)
    COLOR_PAUSED=$(get_json_value "$COLORS_JSON" color7)
    COLOR_CPU=$(get_json_value "$COLORS_JSON" color12)
    COLOR_MEMORY=$(get_json_value "$COLORS_JSON" color2)
    COLOR_LANGUAGE=$(get_json_value "$COLORS_JSON" color13)
    COLOR_WINDOW=$(get_json_value "$COLORS_JSON" color14)
    COLOR_PULSEAUDIO=$(get_json_value "$COLORS_JSON" color11)
    COLOR_PULSEAUDIO_MUTED=$(get_json_value "$COLORS_JSON" color3)
    COLOR_CUSTOM_POWER=$(get_json_value "$COLORS_JSON" color9)
    COLOR_TOOLTIP_BORDER=$(get_json_value "$COLORS_JSON" color6)
else
    # Использовать цвета по умолчанию, если pywal не настроен
    BG_COLOR=$DEFAULT_BG
    BG_ALT_COLOR=$DEFAULT_BG_ALT
    FG_COLOR=$DEFAULT_COLOR
    COLOR_HOVER=$DEFAULT_HOVER_BG
    COLOR_ACTIVE=$DEFAULT_ACTIVE_BG
    COLOR_URGENT=$DEFAULT_URGENT_COLOR
    COLOR_PLAYING=$DEFAULT_PLAYING_COLOR
    COLOR_PAUSED=$DEFAULT_PAUSED_COLOR
    COLOR_CPU=$DEFAULT_CPU_COLOR
    COLOR_MEMORY=$DEFAULT_MEMORY_COLOR
    COLOR_LANGUAGE=$DEFAULT_LANGUAGE_COLOR
    COLOR_WINDOW=$DEFAULT_WINDOW_COLOR
    COLOR_PULSEAUDIO=$DEFAULT_PULSEAUDIO_COLOR
    COLOR_PULSEAUDIO_MUTED=$DEFAULT_PULSEAUDIO_MUTED_COLOR
    COLOR_CUSTOM_POWER=$DEFAULT_CUSTOM_POWER_COLOR
    COLOR_TOOLTIP_BORDER=$DEFAULT_TOOLTIP_BORDER
fi

# Генерация CSS с новыми цветами
cat >"$WAYBAR_CSS" <<EOF
* {
  min-height: 0;
  min-width: 0;
  font-family: "FontAwesome 5", "JetBrainsMono NFP";
  font-size: 11px;
  font-weight: 600;
  color: $BG_COLOR;
}


.modules-left {
  padding-left: 4px;
}

.modules-right {
  padding-right: 4px;
}

window#waybar {
  transition-property: background-color;
  transition-duration: 0.5s;
  background-color: $BG_COLOR;
  border-radius: 10px;
}

#workspaces button {
  padding: 0.3rem 1rem;
  margin: 0.4rem 0.3rem;
  border-radius: 6px;
  background-color: $BG_ALT_COLOR;
  color: $FG_COLOR;
}

#workspaces button:hover {
  color: $COLOR_HOVER;
  background-color: $COLOR_ACTIVE;
}

#workspaces button.active {
  background-color: $COLOR_ACTIVE;
  color: $FG_COLOR;
}

#workspaces button.urgent {
  background-color: $COLOR_ACTIVE;
  color: $COLOR_URGENT;
}

#clock,
#pulseaudio,
#custom-logo,
#custom-power,
#custom-spotify,
#custom-notification,
#cpu,
#tray,
#memory,
#window,
#language,
#network,
#battery,
#mpris {
  padding: 0.3rem 1rem;
  margin: 0.4rem 0.25rem;
  border-radius: 6px;
  background-color: $BG_ALT_COLOR;
}

#mpris.playing {
  background-color: $COLOR_PLAYING;
}

#mpris.paused {
  background-color: $COLOR_PAUSED;
}

#network {
  background-color: $COLOR_PAUSED;
}

#battery {
  background-color: $COLOR_PAUSED;
}

#custom-sep {
  padding: 0px;
  background-color: $COLOR_TOOLTIP_BORDER;
}

window#waybar.empty #window {
  background-color: transparent;
}

#cpu {
  background-color: $COLOR_CPU;
}

#memory {
  background-color: $COLOR_MEMORY;
}

#language {
  background-color: $COLOR_LANGUAGE;
}

#clock {
  background-color: $COLOR_LANGUAGE;
}

#clock.simpleclock {
  background-color: $COLOR_LANGUAGE;
}

#window {
  background-color: $COLOR_WINDOW;
}

#pulseaudio {
  background-color: $COLOR_PULSEAUDIO;
}

#pulseaudio.muted {
  background-color: $COLOR_PULSEAUDIO_MUTED;
}

#custom-logo {
  background-color: $COLOR_MEMORY;
}

#custom-power {
  background-color: $COLOR_CUSTOM_POWER;
}

tooltip {
  background-color: $BG_ALT_COLOR;
  border: 2px solid $COLOR_TOOLTIP_BORDER;
}
EOF

pkill -USR1 waybar
