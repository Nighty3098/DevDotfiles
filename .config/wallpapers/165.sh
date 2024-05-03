#!/bin/bash

i=1
for file in *; do
  if [ -f "$file" ]; then
    new_name=$(printf "%03d" $i)
    mv "$file" "$new_name.${file##*.}"
    ((i++))
  fi
done
