CLICOLOR=1
PAGER='/opt/homebrew/bin/less'
MANPAGER=$PAGER
EDITOR='/opt/homebrew/bin/nano'
VISUAL=$EDITOR
BAT_PAGER='/bin/sh -c "/usr/bin/less \"$LESS\""'

TMPDIR='/private/var/folders/5p/gq6f59c92z7069cb22k_sj100000gn/T'
GPG_TTY=$TTY

#if [[ $LESS != (* |)-([^ ]##|)r([^ ]##|)( *|) ]]
LESS="$LESS -r"
#fi

#if [[ -z $HB_CNF_HANDLER ]]
HB_CNF_HANDLER="/opt/homebrew/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
#fi
