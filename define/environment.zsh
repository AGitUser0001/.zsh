CLICOLOR=1
PAGER="$HOMEBREW_PREFIX/bin/less"
MANPAGER=$PAGER
EDITOR="$HOMEBREW_PREFIX/bin/nano"
VISUAL=$EDITOR
LSCOLORS="exfxcxdxbxegedabagacad"
LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

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
