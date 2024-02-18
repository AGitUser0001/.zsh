#flags -RUz
$fpath[1]/**/[!_]*(-N^/)
$fpath[1]/**/__?*(-N^/)

add-zle-hook-widget
add-zsh-hook
compinit
run-help
zkbd

catch
throw

cdr
zargs
zcalc
zed
zmv

chpwd_recent_dirs
zsh_directory_name_cdr
