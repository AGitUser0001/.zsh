#exec unalias run-help

se=sudoedit
sedit=sudoedit
sudoed=sudoedit
stage-manager='defaults write com.apple.WindowManager GloballyEnabled -int $((1-$(defaults read com.apple.WindowManager GloballyEnabled)))'
compaudit=:
catch='noglob catch'
rm='rm -I'
del='trash -F'
