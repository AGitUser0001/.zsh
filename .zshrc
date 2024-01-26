if [[ ${:P} != $PWD ]] cd ${:P};
SAVEHIST=10000000 HISTSIZE=100000
typeset +x ZLE_PUSH="$ZLE_PUSH"
while { read -rskt } { ZLE_PUSH+=$REPLY }

typeset -xT ZSH_PATH_OVERRIDE zsh_path_override
if [[ -o login && $ZSH_IGNORE_LOGIN != 1 ]] {
  path[${path[(i)/bin]}]=( )
  path[${path[(i)/sbin]}]=( )
  path[${path[(i)/usr/bin]}]=( )
  path[${path[(i)/usr/sbin]}]=( )
  path[${path[(i)/usr/local/bin]}]=( )
  path[${path[(i)/Library/Apple/usr/bin]}]=( )
}

path=(
  ~/.bin/applets
  $zsh_path_override
  ~/.bin
  ~/.dotnet/tools
  $path
  /opt/homebrew/opt/python/bin
  /opt/homebrew/bin /opt/homebrew/sbin
  /opt/homebrew/opt/ruby/bin
  /opt/homebrew/opt/sqlite/bin
  /opt/homebrew/opt/curl/bin
  /Library/Apple/usr/bin
  /usr/local/bin /usr/bin
  /bin /usr/sbin /sbin
  /Library/Frameworks/Mono.framework/Versions/Current/Commands
)

fpath=(
  $ZDOTDIR/functions
  $ZDOTDIR/functions/**(-/N)
  /opt/homebrew/opt/curl/share/zsh/site-functions
  /opt/homebrew/share/zsh-completions
  /opt/homebrew/share/zsh/site-functions
  /opt/homebrew/share/zsh/functions
  $fpath
)

module_path+=(
  /opt/homebrew/lib/zsh
)

fpath[${fpath[(i)/usr/local/share/zsh/site-functions]}]=( )

autoload -Uz $fpath[1]/**/[!_]*(-N^/)

read-definition-file $ZDOTDIR/define/definitions.zsh read-definition-file

() {
  local opts=(-C)
  if [[ -r $ZDOTDIR/.zcomphash ]] {
    mtree -k cksum -p $ZDOTDIR/functions/completion/ < $ZDOTDIR/.zcomphash &>/dev/null
    if (( $? == 2 )) opts=(-u);
  } else { opts=(-u) }
  mtree -ck cksum -p $ZDOTDIR/functions/completion/ > $ZDOTDIR/.zcomphash 2>/dev/null
  compinit $opts && _evf $ZDOTDIR/comp.init.zsh
}

() {
  local fn
  for fn ( ${functions[(I)zmath-?*]} ) {
    local x=${fn##*+} opts=( ) args=( ${${fn%+*}#zmath-} 1 -1 )
    local -a match mbegin mend

    case $x {
      (zmath-*);;
      ((*,|)raw(,*|)) opts+=( -s ) && args[2,3]=( 1 1 );|
      ((#b)(*,|)name=([^,]##)(,*|)) args[1]=$match[2];|
      ((#b)(*,|)min=([0-9]##)(,*|)) args[2]=$match[2];|
      ((#b)(*,|)max=([0-9]##)(,*|)) args[3]=$match[2];|
    }
    functions -M $opts -- $args $fn
  }
}

_default_setup='
  builtin emulate -LR zsh
  builtin setopt extended_glob magic_equal_subst bsd_echo glob_star_short prompt_subst brace_ccl combining_chars c_bases octal_zeroes
'

USER_ZDOTDIR=$ZDOTDIR
[[ $TERM_PROGRAM == "vscode" ]] && _evf "/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/contrib/terminal/browser/media/shellIntegration-rc.zsh"
[[ $TERM_PROGRAM == Apple_Terminal ]] && __nobg="%K{233}" || __nobg="%k"

__lasttimestart=-1
_elapsed=( )
_evf $ZDOTDIR/zle.init.zsh

autoload -Uz $fpath[1]/(^zle)/__?*(-N^/)
add-zsh-hook chpwd chpwd_recent_dirs
add-zsh-hook -Uz zsh_directory_name zsh_directory_name_cdr
() {
  local i
  for i ( $functions[(I)__?*] ) {
    if [[ $functions_source[$i] == $fpath[1]/hooks/(*/)#__?* ]] case ${${${i#__}%%+*}%%\=*} {
      (chpwd|precmd|preexec|periodic) ;&
      (zshaddhistory|zshexit|zsh_directory_name) add-zsh-hook ${${${i#__}%%+*}%%\=*} $i;;
      (isearch-exit|isearch-update|line-pre-redraw|line-init) ;&
      (line-finish|history-line-set|keymap-select) 
        zle -N zle-func-${${i#__}%%+*} $i
        add-zle-hook-widget ${${${i#__}%%+*}%%\=*} zle-func-${${i#__}%%+*};;
      (*) return 1;
    }
  }
}

__reset
CURRENT_GIT_BRANCH=''
TITLE=''
TAB_TITLE=''
WORDCHARS='*?'
HELP_SKIPFUNC=( visudo purge )

PROMPT_EOL_MARK='%k%f%b%s'
PROMPT=$'%K{blue} %3~ %F{blue}%(4V"%K{%1v}%F{%2v} %B%3v%4v%5v%b %F{%1v}")%K{%6v}%F{%7v} %8vs $__nobg%F{%6v} %k%f%b%s%(#"%B%F{red}%#%b%f"%#) '
PROMPT2=$'%K{208}%F{black} $(
  eval $_default_setup
  printf %s ${${(j"  ")${${=${(%):-%_}}}}[1,-12]}
) $__nobg%F{208} %k%f%b%s'
#RPROMPT=$'%(9V.%(?..$__nobg%F{red}%K{red}%f %? ).)'

_evf $HB_CNF_HANDLER

upbrew() {
  brew update
  brew upgrade
  brew cleanup -s
}

_evf $ZDOTDIR/pyutils.zsh
_evf $ZDOTDIR/zstyle.init.zsh

__reset

while { read -rskt } { ZLE_PUSH+=$REPLY }
true # $? == 0
