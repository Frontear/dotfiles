{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.persist;

  mkPersistActivation = (root: cfg:
  let
    dirs = map (e: e.path) cfg.directories;

    parentExists = (path:
    let
      parent = dirOf path;
    in
      parent != root
      && (lib.elem parent dirs
      || parentExists parent)
    );

    uniqueDirs = lib.filter (p: !parentExists p) dirs;
  in lib.concatStringsSep "\n" ((map (e:
    if lib.elem e.path uniqueDirs then
      ''persist "${config.my.persist.volume + e.path}" "${e.path}" "${e.user}" "${e.group}" "${e.mode}" "dir"''
    else
      ''mkown "${config.my.persist.volume + e.path}" "${e.path}" "${e.user}" "${e.group}" "${e.mode}" "dir" ''
  ) cfg.directories) ++ map (e:
    ''persist "${config.my.persist.volume + e.path}" "${e.path}" "${e.user}" "${e.group}" "${e.mode}" "file"''
  ) cfg.files));
in {
  imports = [
    ./module.nix
  ];

  config = lib.mkIf cfg.enable {
    # These directories should logically exist to ensure
    # a consistent and expected system state.
    my.persist.directories = [
      "/var/lib"
      "/var/log"
    ] ++ lib.optionals config.security.sudo.enable [{
      path = "/var/db/sudo/lectured";
      mode = "700";
    }];

    # Ensure consistency with some systemd tools.
    my.persist.files = [{
      path = "/etc/machine-id";
      mode = "444";
    }];

    system.activationScripts.persist = lib.stringAfter [ "users" "groups" ] ''
      log() {
        echo "[persist] $1"
      }

      # $1 - Path to entry in the persisted volume
      # $2 - Absolute path to entry as it will be on the rootfs
      # $3 - User value for permissions
      # $4 - Group value for permissions
      # $5 - Mode value for permissions
      # $6 - Enum of either "dir" or "file"
      mkown() {
        # Create all the parent paths with sane default permissions.
        # This is usually only necessary in cases where the persist
        # entry was made new, and has not existed in previous contexts
        mkdir -pv "$(dirname "$1")" "$(dirname "$2")" | ${lib.getExe pkgs.gnused} "s|'||g;s|.* ||g" | while read -r dir; do
          log "mkown: mkdir $dir '$3:$4' 755"
          chown "$3:$4" "$dir"
          chmod "755" "$dir"
        done

        # Create the entry if it does not exist within the persist volume.
        # We use either mkdir or touch depending on the type of entry.
        if [ ! -e "$1" ]; then
          log "mkown: mkent $1"
          (test "$6" = "dir" && mkdir -p "$1") || (test "$6" = "file" && touch "$1")
        fi
        
        # Create the entry if it does not exist on the rootfs.
        # This is necessary for the bind mount to succeed in persist.
        if [ ! -e "$2" ]; then
          log "mkown: mkent $2"
          (test "$6" = "dir" && mkdir -p "$2") || (test "$6" = "file" && touch "$2")
        fi

        # Correctly enforce desired permissions on the entry in the persist.
        log "mkown: ch{mod,own} $1"
        chown "$3:$4" "$1"
        chmod "$5" "$1"
      }

      # $1 - Path to entry in the persisted volume
      # $2 - Absolute path to entry as it will be on the rootfs
      # $3 - User value for permissions
      # $4 - Group value for permissions
      # $5 - Mode value for permissions
      # $6 - Enum of either "dir" or "file"
      persist() {
        # Ensure the existence of the directory tree with sufficient
        # permissions beforehand. This will not replace anything that
        # already exists, it is non-destructive.
        mkown "$1" "$2" "$3" "$4" "$5" "$6"

        # Fast fail in situations where the entry is already linked.
        # This usually happens when we perform a switch-to-configuration
        # on a running system.
        if [ "$1" -ef "$2" ]; then
          log "persist: skip $1 ==> $2"
          return 0
        fi

        # Create the bind mount onto the rootfs. We make the assumption
        # that this entry does not exist, as we performed a 'test -ef'
        # check earlier on.
        log "persist: bind $1 ==> $2"
        mount -o bind "$1" "$2"
      }

      ${mkPersistActivation "/" cfg}
      ${lib.pipe config.home-manager.users [
        lib.attrValues
        (map (cfg: mkPersistActivation cfg.home.homeDirectory cfg.my.persist))
        (lib.concatStringsSep "\n")
      ]}
    '';
  };
}
