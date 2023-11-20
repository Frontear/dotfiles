{ ... }:
{
    # allow "non-free" firmware
    nixpkgs.config.allowUnfree = true;
    
    # enable all firmware packages
    hardware.enableAllFirmware = true;

    # force enable microcode updates
    hardware.cpu = {
        amd.updateMicrocode = true;
        intel.updateMicrocode = true;
    };
}
