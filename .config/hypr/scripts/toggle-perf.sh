#!/bin/bash
FLAG="/tmp/hypr-perf-mode"

if [ -f "$FLAG" ]; then
    rm "$FLAG"
    hyprctl keyword animations:enabled true
    echo "Оптимизации ВЫКЛ — анимации включены"
else
    touch "$FLAG"
    hyprctl keyword animations:enabled false
    echo "Оптимизации ВКЛ — анимации выключены"
fi
