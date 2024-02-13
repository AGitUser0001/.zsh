#exec source $ZDOTDIR/homebrew-env.sh

CLICOLOR=1
PAGER="$HOMEBREW_PREFIX/bin/less"
MANPAGER=$PAGER
EDITOR="$HOMEBREW_PREFIX/bin/nano"
VISUAL=$EDITOR

TMPDIR='/private/var/folders/5p/gq6f59c92z7069cb22k_sj100000gn/T'
GPG_TTY=$TTY

#if [[ $LESS != (*[[:space:]]|)-([^[:space:]]##|)r* ]]
LESS="$LESS -r"
#fi
#if [[ $LESS != (*[[:space:]]|)-([^[:space:]]##|)i* ]]
LESS="$LESS -i"
#fi

#if [[ -z $HB_CNF_HANDLER ]]
HB_CNF_HANDLER="$HOMEBREW_PREFIX/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
#fi
