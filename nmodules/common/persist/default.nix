{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) concatStringsSep replaceStrings;
  inherit (lib) concatLists forEach getExe mapAttrsToList mkEnableOption mkOption optionals types;

  system-persist = let cfg = config.my.system.persist; in optionals cfg.enable ((forEach cfg.directories (d: ''persistDir "${cfg.volume + d.path}" "${d.path}" "${d.user}" "${d.group}" "${d.mode}"'')) ++ (forEach cfg.files (f: ''persistFile "${cfg.volume + f.path}" "${f.path}" "${f.user}" "${f.group}" "${f.mode}"'')));
  user-persist = concatLists (forEach (mapAttrsToList (_: v: v.persist) config.my.users) (cfg: optionals cfg.enable ((forEach cfg.directories (d: ''persistDir "${cfg.volume + d.path}" "${d.path}" "${d.user}" "${d.group}" "${d.mode}"'')) ++ (forEach cfg.files (f: ''persistFile "${cfg.volume + f.path}" "${f.path}" "${f.user}" "${f.group}" "${f.mode}"'')))));
  all-persist = system-persist ++ user-persist;

  pathOpts = name: username: group: {
    options = {
      path = mkOption {
        default = null;
        description = ''
          Absolute path to the ${name}.
        '';
        type = types.str;
      };

      user = mkOption {
        default = username;
        description = ''
          User who owns this ${name}.
        '';
        type = types.str;
      };

      group = mkOption {
        default = group;
        description = ''
          Group that owns this ${name}.
        '';
        type = types.str;
      };

      mode = mkOption {
        default = if name == "directory" then "755" else "644";
        description = ''
          Modifiers applied to this ${name}.
        '';
        type = types.str;
      };
    };
  };

  mkPersistOption = ({ name, username, group, from, to, file_example, dir_example }: {
    enable = mkEnableOption "persist ${name} paths across ephemeral roots.";
    volume = mkOption {
      default = "/nix/persist";
      description = ''
        The volume where persisted paths are stored and linked against.
      '';
    };
    directories = mkOption {
      default = [];
      example = dir_example;
      description = ''
        Directories from the ${name} to persistently store.
      '';
      type = with types; listOf (coercedTo str (d: { path = d; }) (submodule (pathOpts "directory" username group)));
      apply = v: map (x: x // { path = (replaceStrings from to x.path); }) v;
    };
    files = mkOption {
      default = [];
      example = file_example;
      description = ''
        Files from the ${name} to persistently store.
      '';
      type = with types; listOf (coercedTo str (f: { path = f; }) (submodule (pathOpts "file" username group)));
      apply = v: map (x: x // { path = (replaceStrings from to x.path); }) v;
    };
  });

  userOpts = { name, config, ... }: {
    options.persist = mkPersistOption {
      name = "user";
      username = config.username;
      group = "users";
      from = [ "~" ];
      to = [ config.homeDirectory ];

      dir_example = [
        "~/.ssh"
        { path = "~/.gnupg"; user = config.username; group = "users"; mode = "700"; }
      ];

      file_example = [
        "~/.bash_history"
        { path = "~/.local/share/lesshst"; user = config.username; group = "users"; mode = "600"; }
      ];
    };
  };
in {
  options = {
    my.system.persist = mkPersistOption {
      name = "system";
      username = "root";
      group = "root";
      from = [];
      to = [];

      dir_example = [
        "/etc/NetworkManager"
        { path = "/etc/nixos"; user = "root"; group = "wheel"; mode = "755"; }
      ];

      file_example = [
        "/etc/machine-id"
        { path = "/etc/shadow"; user = "root"; group = "shadow"; mode = "640"; }
      ];
    };

    my.users = mkOption {
      type = with types; attrsOf (submodule userOpts);
    };
  };

  config = {
    system.activationScripts.copy-persisted = lib.stringAfter [ "users" "groups" ] (''
      # $1 - Path to file/directory written in the persisted volume
      # $2 - Absolute path to where the file/directory will be placed
      # $3 - User value for 'chown'
      # $4 - Group value for 'chown'
      # $5 - Mode value for 'chown'
      #
      # !root && !persist:
      #   - touch on persist, sync perms, link persist -> root
      # !root && persist:
      #   - sync perms, link persist -> root
      # root && !persist:
      #   - cp + rm from root, sync perms, link persist -> root
      # root && persist:
      #   - ignore
      #
      function persistFile() {
        mkdir -pv "$(dirname "$1")" "$(dirname "$2")" | ${getExe pkgs.gnused} "s|'||g;s|.* ||g" | while read dir; do
          echo "Creating $dir with $3:$4, $5"
          chown "$3:$4" "$dir"
          chmod "755" "$dir"
        done

        if [ -f "$1" ] && [ -f "$2" ] && [ "$1" -ef "$2" ]; then
          echo "Already linked, ignoring"
          return 0
        fi

        if [ ! -f "$1" ]; then
          echo "Need to make $1"
          touch "$1"
        fi

        echo chown "$3:$4" "$1"
        chown "$3:$4" "$1"
        echo chmod "$5" "$1"
        chmod "$5" "$1"
        echo touch "$2"
        touch "$2"
        echo mount -o bind "$1" "$2"
        mount -o bind "$1" "$2"
      }

      # $1 - Path to file/directory written in the persisted volume
      # $2 - Absolute path to where the file/directory will be placed
      # $3 - User value for 'chown'
      # $4 - Group value for 'chown'
      # $5 - Mode value for 'chown'
      #
      # !root && !persist:
      #   - mkdir on persist, sync perms, bind persist -> root
      # !root && persist:
      #   - sync perms, bind persist -> root
      # root && !persist:
      #   - cp + rm -r from root, sync perms, bind persist -> root
      # root && persist:
      #   - ignore
      #
      function persistDir() {
        mkdir -pv "$(dirname "$1")" "$(dirname "$2")" | ${getExe pkgs.gnused} "s|'||g;s|.* ||g" | while read dir; do
          echo "Creating $dir with $3:$4, $5"
          chown "$3:$4" "$dir"
          chmod "755" "$dir"
        done

        if [ -d "$1" ] && [ -d "$2" ] && [ "$1" -ef "$2" ]; then
          echo "$1 => $2 already, ignoring"
          return 0
        fi

        if [ ! -d "$1" ]; then
          echo "Need to make $1"
          mkdir -p "$1"
        fi

        echo chown "$3:$4" "$1"
        chown "$3:$4" "$1"
        echo chmod "$5" "$1"
        chmod "$5" "$1"
        echo mkdir -p "$2"
        mkdir -p "$2"
        echo mount -o bind "$1" "$2"
        mount -o bind "$1" "$2"
      }

    '' + concatStringsSep "\n" all-persist);
  };
}
