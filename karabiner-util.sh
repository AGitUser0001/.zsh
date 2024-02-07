#!/bin/sh
source ${0#/*}/homebrew-env.sh

menu() {
  script 'tell application "System Events" to tell (first process where it is frontmost) to click '"$1"' of menu bar 1'
}

script() {
  osascript -e "$1" >/dev/null
}

app() {
  open -a "$1"
}

play() {
  afplay /System/Library/Sounds/$1.aiff
}

notify() {
  if (( $# == 1 )); then
    $HOMEBREW_PREFIX/bin/terminal-notifier -remove "$1"
  elif (( $# == 2 || $# == 3 )); then
    $HOMEBREW_PREFIX/bin/terminal-notifier -sender org.pqrs.Karabiner-NotificationWindow -title Karabiner-Elements -message "$2" -group "$3"
  elif (( $# == 4 )); then
    $HOMEBREW_PREFIX/bin/terminal-notifier -sender org.pqrs.Karabiner-NotificationWindow -title "$2" -message "$3" -group "$4"
  fi
}
