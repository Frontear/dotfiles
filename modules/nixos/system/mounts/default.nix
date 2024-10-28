{
  config,
  lib,
  ...
}:
let
  cfg = config.my.mounts;
in {
  options.my.mounts = {
    boot.label = lib.mkOption {
      default = "EFI";

      type = with lib.types; str;
    };

    nix.label = lib.mkOption {
      default = "store";

      type = with lib.types; str;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.my.boot.systemd-boot.enable {
      fileSystems."/boot" = {
        device = "/dev/disk/by-label/${cfg.boot.label}";
        fsType = "vfat";
        options = [ "noatime" ];
      };
    })

    (lib.mkIf config.my.persist.enable {
      fileSystems = {
        "/" = {
          device = "none";
          fsType = "tmpfs";
          options = [ "mode=755" "noatime" "size=1G" ];
        };

        "/nix" = {
          device = "/dev/disk/by-label/${cfg.nix.label}";
          fsType = "ext4";
          options = [ "noatime" ];
        };
      };
    })
  ];
}
