# https://wiki.archlinux.org/title/XDG_Base_Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export RUSTUP_HOME=$XDG_CACHE_HOME/rustup
export CARGO_HOME=$XDG_CACHE_HOME/cargo
export GNUPGHOME=$XDG_DATA_HOME/gnupg

export _JAVA_OPTIONS=-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java

# https://wiki.archlinux.org/title/GNOME/Keyring
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh

export PATH="$HOME/.local/bin:$PATH:$CARGO_HOME/bin"
