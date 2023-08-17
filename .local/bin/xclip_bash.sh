#!/bin/bash

filename="$1"

cat "$filename" | xclip -selection clipboard
