#
# .cshrc - csh resource script, read at beginning of execution by each shell
#
# see also csh(1), environ(7).
# more examples available at /usr/share/examples/csh/
#

alias h         history 25
alias j         jobs -l
alias la        ls -aF
alias lf        ls -FA
alias ll        ls -lAF

alias non ls -tra
alias jk clear
alias eu df -h .
alias il iocell list
alias ic iocell console
alias istart iocell start
alias istop iocell stop

# A righteous umask
umask 22

set path = (/sbin /bin /usr/sbin /usr/bin /usr/local/sbin /usr/local/bin $HOME/bin $HOME/go/bin /usr/local/go/bin)

setenv  EDITOR  vi
setenv  PAGER   less
setenv  BLOCKSIZE       K

if ($?prompt) then
        # An interactive shell -- set some stuff up
        set prompt = "%N@%m:%~ %# "
        set promptchars = "%#"

        set filec
        set history = 1000
        set savehist = (1000 merge)
        set autolist = ambiguous
        # Use history to aid expansion
        set autoexpand
        set autorehash
        set mail = (/var/mail/$USER)
        if ( $?tcsh ) then
                bindkey "^W" backward-delete-word
                bindkey -k up history-search-backward
                bindkey -k down history-search-forward
        endif

endif
 
set prompt = "%N@%m:%~ %# "
set promptchars = "%#"

# user variation
#set prompt="%{\e[32;1m%}%n%{\e[37m%}@%{\e[0;36m%}%m%{\e[37m%}:%{\e[33m%}%~%{\e[37m%}"\$"%{\e[0m%} "

# root variation:
#set prompt="%{\e[31;1m%}root%{\e[37m%}@%{\e[33m%}%m%{\e[37m%}:%{\e[36m%}%/%{\e[37m%}#%{\e[0m%} "
