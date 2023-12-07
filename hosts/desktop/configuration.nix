{ config, pkgs, ... }: {
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/nvme0n1";
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.memtest86.enable = true;
    boot.loader.grub.timeoutStyle = "hidden";
    boot.loader.grub.useOSProber = true;

    hardware.bluetooth.enable = true;
    hardware.cpu.amd.updateMicrocode = true;
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
    hardware.nvidia.modesetting.enable = true;
    hardware.opengl.extraPackages = with pkgs; [
        libvdpau-va-gl
        nvidia-vaapi-driver
        vaapiVdpau
    ];

    services.xserver.videoDrivers = [ "nvidia" ];
}
