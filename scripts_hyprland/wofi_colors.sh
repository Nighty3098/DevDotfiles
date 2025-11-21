#!/bin/bash

PYWAL_COLORS="$HOME/.cache/wal/colors.json"
WOFI_CSS="$HOME/.config/wofi/style.css"

get_json_value() {
    echo "$1" | grep -oP '"'"$2"'": *"\K[^"]*'
}

# Подгрузка цветов из pywal или установка дефолтных
if [ -f "$PYWAL_COLORS" ]; then
    COLORS_JSON=$(cat "$PYWAL_COLORS")

    BG=$(get_json_value "$COLORS_JSON" color0)
    FG=$(get_json_value "$COLORS_JSON" foreground)
    ACCENT=$(get_json_value "$COLORS_JSON" color9)
    SELECTED_BG=$(get_json_value "$COLORS_JSON" color7)
    SELECTED_FG=$(get_json_value "$COLORS_JSON" color0)
else
    BG="#141415"
    FG="#cdcdcd"
    ACCENT="#d8647e"
    SELECTED_BG="#aeaed1"
    SELECTED_FG="#141415"
fi

# Создаём CSS с подставленными цветами
cat >"$WOFI_CSS" <<EOF
* {
  font-family: "Iosevka", monospace;
  font-size: 14px;
}

/* Window */
window {
  margin: 0px;
  padding: 10px;
  border: none;
  border-radius: 1rem;
  background-color: $BG;
  animation: slideIn 0.5s ease-in-out both;
}

/* Slide In */
@keyframes slideIn {
  0% {
    opacity: 0;
  }

  100% {
    opacity: 1;
  }
}

/* Inner Box */
#inner-box {
  margin: 5px;
  padding: 10px;
  border: none;
  background-color: $BG;
  animation: fadeIn 0.5s ease-in-out both;
}

/* Fade In */
@keyframes fadeIn {
  0% {
    opacity: 0;
  }

  100% {
    opacity: 1;
  }
}

/* Outer Box */
#outer-box {
  margin: 5px;
  padding: 10px;
  border: none;
  background-color: $BG;
}

/* Scroll */
#scroll {
  margin: 0px;
  padding: 10px;
  border: none;
  background-color: $BG;
}

/* Input */
#input {
  margin: 5px 20px;
  padding: 10px;
  border: none;
  border-radius: 2rem;
  color: $FG;
  background-color: transparent;
  animation: fadeIn 0.5s ease-in-out both;
}

#input image {
  border: none;
  color: $ACCENT;
}

#input * {
  outline: 4px solid $ACCENT !important;
}

/* Text */
#text {
  margin: 5px;
  border: none;
  color: $FG;
  animation: fadeIn 0.5s ease-in-out both;
}

#entry {
  background-color: $BG;
}

#entry arrow {
  border: none;
  color: $FG;
}

/* Selected Entry */
#entry:selected {
  border-radius: 1rem;
  color: $SELECTED_FG;
  background-color: $SELECTED_BG;
}

#entry:selected #text {
  color: $SELECTED_FG;
}

#entry:drop(active) {
  background-color: $BG !important;
}
EOF

# Если нужно, перезапустите wofi (обычно это делается вручную)
echo "Цвета обновлены в $WOFI_CSS. Перезапустите wofi для применения."
