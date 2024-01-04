# https://wiki.archlinux.org/title/XDG_Base_Directory#User_directories

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# https://wiki.archlinux.org/title/XDG_Base_Directory#Support

export CARGO_HOME="$XDG_DATA_HOME/cargo"
# export DISCORD_USER_DATA_DIR="${XDG_DATA_HOME}/discord" # officially undocumented, but used
export FFMPEG_DATADIR="$XDG_CONFIG_HOME/ffmpeg"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GOPATH="$XDG_DATA_HOME/go"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export GTK_RC_FILES="$XDG_CONFIG_HOME/gtk-1.0/gtkrc"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME/java"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME/pass"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
# export VSCODE_PORTABLE="$XDG_DATA_HOME/vscode" # undocumented and unreliable
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export PYTHONUSERBASE="$XDG_DATA_HOME/python"
# TODO: sbcl support
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# https://wiki.archlinux.org/title/GnuPG#SSH_agent

unset SSH_AGENT_PID
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

# ranger --copy-config=rc
export RANGER_LOAD_DEFAULT_RC="FALSE"

export PATH="$HOME/.local/bin:$PATH:$CARGO_HOME/bin"
