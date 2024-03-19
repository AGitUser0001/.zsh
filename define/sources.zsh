$ZDOTDIR/pyutils.zsh
# $ZDOTDIR/zstyle.init.zsh

#if compinit -C
$ZDOTDIR/comp.init.zsh
#fi

#if [[ $TERM_PROGRAM == "vscode" ]]
"/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/contrib/terminal/browser/media/shellIntegration-rc.zsh"
#fi

$HB_CNF_HANDLER
#if (( ! ZSH_DEBUG ))
$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#exec ZSH_AUTOSUGGEST_STRATEGY=( history completion )
$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#exec ZSH_HIGHLIGHT_HIGHLIGHTERS+=( brackets )
#fi
