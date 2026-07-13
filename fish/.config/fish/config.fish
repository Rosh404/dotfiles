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
set -x GRADLE_HOME /usr/local/gradle
set -x KOTLIN_HOME $HOME/.local/bin

set -x PATH $PATH \
    $GOROOT/bin \
    $GOPATH/bin \
    $JAVA_HOME/bin \
    $MAVEN_HOME/bin \
    $LUA_HOME/bin \
    $JDTLS_HOME/bin \
    $GRADLE_HOME/bin \
    $KOTLIN_HOME

#set -x PATH $PATH $HOME/.local/bin

set -U fish_greeting

starship init fish | source

# Keybind
function my_fzf_preview
    # 1. Run fzf and capture the selection
    set -l selection (fzf --preview="bat --color=always {}")
    
    # 2. If a selection was made, insert it into the current command line
    if test -n "$selection"
        commandline -i -- "$selection"
    end
    
    # 3. Refresh the command line to show the inserted text
    commandline -f repaint
end

bind --mode insert \cf my_fzf_preview

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

fzf --fish | source

function fgit
    git ls-files -m -o --exclude-standard | fzf \
        --height 100% \
        --layout=reverse \
        --border \
        --preview 'git diff --color=always -- {-1} | delta' \
        --bind 'enter:execute(git diff --color=always {-1} | delta | less -R)'
end

function rfv
    # 1. Define the reload command
    set -l reload_cmd 'reload:rg --column --color=always --smart-case {q} || :'
    
    # 2. Define the opener logic
    # Note: Using fish -c for the bash-like conditional inside the binding
    set -l opener 'if test $FZF_SELECT_COUNT -eq 0; 
                     nvim {1} +{2}; 
                   else; 
                     nvim +cw -q {+f}; 
                   end'

    # 3. Execute fzf
    fzf --disabled --ansi --multi \
        --bind "start:$reload_cmd" \
        --bind "change:$reload_cmd" \
        --bind "enter:become:$opener" \
        --bind "ctrl-o:execute:$opener" \
        --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
        --delimiter : \
        --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
        --preview-window '~4,+{2}+4/3,<80(up)' \
        --query "$argv"
end

# Define the function to toggle between fg and bg
function toggle_job
    # Get the current job ID if it exists
    set -l last_job (jobs -l | tail -n1 | awk '{print $1}')
    
    if test -n "$last_job"
        # If there is a job, bring it to the foreground
        fg %$last_job
    else
        # If no job is in the background, send the current foreground process to the background
        # Note: Fish handles Ctrl+Z differently; usually, it suspends automatically.
        # This part assumes you are in a situation where you need to manually toggle.
        commandline -f repaint
    end
end

# Bind Ctrl+Z to the function
bind \cz toggle_job

source $HOME/.config/op/plugins.sh
