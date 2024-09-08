{
  config,
  lib,
  pkgs,
  ...
}:
let
  pathOpts = { user, group, name, ... } @ pathAttrs: {
    options = {
      path = lib.mkOption {
        default = null;
        description = ''
          Absolute path to the ${name} as it should be on the rootfs.
        '';
      } // lib.removeAttrs pathAttrs [ "user" "group" "name" "default" "description" ];

      user = lib.mkOption {
        default = user;
        description = ''
          The user who owns this ${name}.
        '';

        type = with lib.types; str;
      };

      group = lib.mkOption {
        default = group;
        description = ''
          The group who owns this ${name}.
        '';

        type = with lib.types; str;
      };

      mode = lib.mkOption {
        default = if name == "directory" then "755" else "644";
        description = ''
          The permission modifiers applied to this ${name}.
        '';

        type = with lib.types; str;
      };
    };
  };

  mkPersistenceModuleOpts = { user, group, optPathAttrs, dir-example, file-example }: {
    enable = lib.mkEnableOption "persist path entries across ephemeral roots.";

    volume = lib.mkOption {
      default = "/nix/persist";
      description = ''
        The persistent volume where all entries are stored and linked to the rootfs.
      '';

      type = with lib.types; path;
    };

    directories = lib.mkOption {
      default = [];
      description = ''
        Directories to persistently store. These are bind mounted upon system activation.
      '';

      example = dir-example;
      type = with lib.types; listOf (coercedTo str (path: { inherit path; }) (submodule (pathOpts ({
        inherit user group;
        name = "directory";
      } // optPathAttrs))));
    };

    files = lib.mkOption {
      default = [];
      description = ''
        Files to persistently store. These are bind mounted upon system activation.
      '';

      example = file-example;
      type = with lib.types; listOf (coercedTo str (path: { inherit path; }) (submodule (pathOpts {
        inherit user group;
        name = "file";
      } // optPathAttrs)));
    };
  };
in {
  options.my.persist = mkPersistenceModuleOpts {
    user = "root";
    group = "root";

    optPathAttrs = {
      type = with lib.types; systemPath;
    };

    dir-example = [
      "/etc/NetworkManager"
      { path = "/etc/nixos"; user = "root"; group = "wheel"; mode = "755"; }
    ];

    file-example = [
      "/etc/machine-id"
      { path = "/etc/shadow"; user = "root"; group = "shadow"; mode = "640"; }
    ];
  };

  config = {
    my.persist.directories = lib.lists.flatten (lib.mapAttrsToList (_: value: value.my.persist.directories) config.home-manager.users);

    my.persist.files = lib.lists.flatten (lib.mapAttrsToList (_: value: value.my.persist.files) config.home-manager.users);

    system.activationScripts.copy-persisted = lib.stringAfter [ "users" "groups" ] ''
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
        mkdir -pv "$(dirname "$1")" "$(dirname "$2")" | ${lib.getExe pkgs.gnused} "s|'||g;s|.* ||g" | while read dir; do
          echo "Creating $dir with $3:$4, $5"
          chown "$3:$4" "$dir"
          chmod "755" "$dir"
        done

        if [ -f "$1" ] && [ -f "$2" ] && [ "$1" -ef "$2" ]; then
          echo "$1 => $2 already, ignoring"
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
        mkdir -pv "$(dirname "$1")" "$(dirname "$2")" | ${lib.getExe pkgs.gnused} "s|'||g;s|.* ||g" | while read dir; do
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

      ${if config.my.persist.enable then (lib.pipe config.my.persist.directories [
        (map (x: ''persistDir "${config.my.persist.volume + x.path}" "${x.path}" "${x.user}" "${x.group}" "${x.mode}"''))
        (lib.concatStringsSep "\n")
      ]) else "# No persistence!"}

      ${if config.my.persist.enable then (lib.pipe config.my.persist.files [
        (map (x: ''persistFile "${config.my.persist.volume + x.path}" "${x.path}" "${x.user}" "${x.group}" "${x.mode}"''))
        (lib.concatStringsSep "\n")
      ]) else "# No persistence!"}
    '';

    home-manager.sharedModules = [
      (
        {
          osConfig,
          config,
          lib,
          ...
        }:
        {
          options.my.persist = lib.removeAttrs (mkPersistenceModuleOpts {
            user = config.home.username;
            group = osConfig.users.extraUsers.${config.home.username}.group; # TODO: dangerous assumption?

            optPathAttrs = {
              type = with lib.types; userPath;
              apply = lib.replaceStrings [ "~" ] [ config.home.homeDirectory ];
            };

            dir-example = [
              "~/.ssh"
              { path = "~/.gnupg"; user = config.home.username; group = "users"; mode = "700"; }
            ];

            file-example = [
              "~/.bash_history"
              { path = "~/.local/share/lesshst"; user = config.home.username; group = "users"; mode = "600"; }
            ];
          }) [ "enable" "volume" ]; # These are system-only values
        }
      )
    ];
  };
}