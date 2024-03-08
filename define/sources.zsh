$ZDOTDIR/pyutils.zsh
$ZDOTDIR/zle.init.zsh
$ZDOTDIR/zstyle.init.zsh

#if compinit -C
$ZDOTDIR/comp.init.zsh
#fi

#if [[ $TERM_PROGRAM == "vscode" ]]
"/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/contrib/terminal/browser/media/shellIntegration-rc.zsh"
#fi

$HB_CNF_HANDLER
/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#exec ZSH_AUTOSUGGEST_STRATEGY=( history completion )
