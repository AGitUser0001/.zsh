$ZDOTDIR/pyutils.zsh
$ZDOTDIR/zle.init.zsh
$ZDOTDIR/zstyle.init.zsh

#if compinit -C
#exec compdump &|
$ZDOTDIR/comp.init.zsh
#fi

#if [[ $TERM_PROGRAM == "vscode" ]]
"/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/contrib/terminal/browser/media/shellIntegration-rc.zsh"
#fi

$HB_CNF_HANDLER
