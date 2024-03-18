# command line help
'^[H'             run-help            '^[h'         run-help

# delete and insert
'^[('             delete-word         '^[[3;5~'     delete-word
'^[[7;5~'         backward-delete-word

# buffer operations
'^Z'              undo                '^R'          redo
'^[q'             push-line-or-edit   '^[Q'         push-line-or-edit


# cursor movement
'^[[H'            beginning-of-line   '^[[1;5D'     backward-word
'^[[F'            end-of-line         '^[[1;5C'     forward-word

# other
'^[[I'            zle-focus           '^[[O'        zle-blur
-M menuselect '^[[I' redisplay '^[[O' redisplay
#if (( ! $+widgets[zle-focus] ))
'^[[I' blank-key
#fi
#if (( ! $+widgets[zle-blur] ))
'^[[O' blank-key
#fi

# history search
${key[PageUp]:-'^[[5~'}                 history-incremental-search-backward
${key[PageDown]:-'^[[6~'}               history-incremental-search-forward

# menu completion
'^I'              menu-complete       '^[[Z'        reverse-menu-complete
-M menuselect  ${key[Backspace]:-'^?'}  send-break
-M menuselect  '^['                     send-break
-M menuselect  '^[[1;2C'                history-incremental-search-forward
-M menuselect  '^[[1;2D'                history-incremental-search-backward
-M menuselect  '^[[5~'                  backward-word
-M menuselect  '^[[5~'                  backward-word
-M menuselect  '^[[6~'                  forward-word
-M menuselect  '^[[Z'                   reverse-menu-complete
-M menuselect  '^[^M'                   accept-and-infer-next-history
