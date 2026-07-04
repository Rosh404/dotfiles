if status is-interactive
    # Commands to run in interactive sessions can go here
end

if not set -q $WEZTERM_PANE
  set -x NVIM_LISTEN_ADDRESS "/tmp/nvim$WEZTERM_PANE"
end

set -gx EDITOR vim

set -x JDTLS_HOME /usr/local/java/jdtls/jdt-language-server-1.60.0-202606262232
set -x LUA_HOME /usr/local/lua
set -x MAVEN_HOME /usr/local/maven/apache-maven-3.9.16
set -x JAVA_HOME /usr/local/java/jdk-26.0.1
set -x GOROOT /usr/local/go
set -x GOPATH $HOME/go
#set -x GOPATH /usr/local/go
set -x NODEJS_HOME /usr/local/node/bin

set -x PATH $PATH \
    $GOROOT/bin \
    $GOPATH/bin \
    $JAVA_HOME/bin \
    $MAVEN_HOME/bin \
    $LUA_HOME/bin \
    $JDTLS_HOME/bin

#set -x PATH $PATH $HOME/.local/bin

set -U fish_greeting

starship init fish | source

# Keybind
bind --mode insert \cf 'tmux-sessionizer'

# Alias
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --group-directories-first"
alias lsl="eza --color=always --icons=always --long --group-directories-first"
alias lst="eza -T --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --group-directories-first"

# Abbreviation
abbr -a cls clear
abbr -a dfu sudo dnf update -y
abbr -a dfi sudo dnf install

# VI Mode
function fish_user_key_bindings
    # Execute this once per mode that emacs bindings should be used in
    fish_default_key_bindings -M insert

    # Then execute the vi-bindings so they take precedence when there's a conflict.
    # alias ll ll --group-directories-first
    # Without --no-erase fish_vi_key_bindings will default to
    # resetting all bindings.
    # The argument specifies the initial mode (insert, "default" or visual).
    fish_vi_key_bindings --no-erase insert
end

source $HOME/.config/op/plugins.sh
