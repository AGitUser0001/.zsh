':completion:*'               insert-tab        false
':completion:*'               verbose           true
':completion:*'               group-name        ''
':completion:*'               menu              select
':completion:*'               matcher-list      'm:{a-zA-Z}={A-Za-z}'
':completion:*'               completer         _oldlist _prefix _complete _match _ignored
':completion:*:messages'      format            '%d'
':completion:*:warnings'      format            'No matches for: %d'
':completion:*:prefix:*'      add-space         true
':completion:*:descriptions'  format            '%B%d%b'
':completion:*'               list-colors       "${(s.:.)LS_COLORS}"
':completion:*'               special-dirs      true

':prompt:X:git:*:dirty:*'     symbol            '*'
