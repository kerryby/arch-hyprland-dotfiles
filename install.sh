#!/bin/bash
# Симлинки для dotfiles

ln -sf "$PWD/.zshrc" ~/.zshrc
ln -sf "$PWD/.bashrc" ~/.bashrc

for dir in .config/*/; do
  mkdir -p "$HOME/$dir"
  for file in "$dir"*; do
    ln -sf "$PWD/$file" "$HOME/$file"
  done
done
