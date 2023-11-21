{ ... }:
{
    # TODO: this vs enableRedistributableFirmware
    nixpkgs.config.allowUnfree = true;
    hardware.enableAllFirmware = true;

    # TODO: how this work?
    hardware.sensor.hddtemp = {
        enable = true;
        drives = [ "/dev/nvme0n1" ];
    };

    # drive and filesystem health
    services.fstrim.enable = true;
    services.btrfs.autoScrub = {
        enable = true;
        fileSystems = [ "/archive" ];
    };
}
