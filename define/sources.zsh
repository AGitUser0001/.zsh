$ZDOTDIR/pyutils.zsh
$ZDOTDIR/zle.init.zsh
$ZDOTDIR/zstyle.init.zsh

#if compinit -u
$ZDOTDIR/comp.init.zsh
#endif

#if [[ $TERM_PROGRAM == "vscode" ]]
"/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/contrib/terminal/browser/media/shellIntegration-rc.zsh"
#endif

$HB_CNF_HANDLER
