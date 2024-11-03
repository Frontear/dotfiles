# Frontear's Dotfiles

Massively WIP!

## TODO

### Persist Directories

```console
$ nix shell nixpkgs#fd
$ sudo fd --one-file-system --base-directory / --type f --hidden --exclude "{tmp,etc/passwd}"
```

#### Generic
- `/etc/machine-id`
- `/var/lib`
- `/var/log`

#### Element
- `~/.config/Element`

#### GnuPG
- `~/.local/share/gnupg`

#### Legcord
- `~/.config/legcord`

#### LibreOffice
- `~/.config/libreoffice`

#### Microsoft Edge
- `~/.cache/Microsoft/Edge`
- `~/.cache/microsoft-edge`
- `~/.config/microsoft-edge`

#### NeoVIM
- `~/.local/state/nvim`

#### NetworkManager
- `/etc/NetworkManager/system-connections`

#### SSH
- `~/.ssh`

#### Sudo
- `/var/db/sudo/lectured`

#### TuiGreet
- [x] `/var/cache/tuigreet`

#### ZSH
- `~/.local/share/zsh`
