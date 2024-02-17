autoload -Uz zstyle+

zstyle+ ':completion:*'           insert-tab        false                                       \
      + ''                        verbose           true                                        \
      + ''                        group-name        ''                                          \
      + ''                        menu              select                                      \
      + ''                        matcher-list      'm:{a-zA-Z}={A-Za-z}'                       \
      + ''                        completer         _oldlist _prefix _complete _match _ignored  \
      + ':messages'               format            '%d'                                        \
      + ':warnings'               format            'No matches for: %d'                        \
      + ':prefix:*'               add-space         true                                        \
      + ':descriptions'           format            '%B%d%b'                                    \
      + ''                        list-colors       "${(s.:.)LS_COLORS}"                        \
      + ''                        special-dirs      true                                        \

zstyle  ':prompt:X:git:*:dirty:'  symbol            '*'
