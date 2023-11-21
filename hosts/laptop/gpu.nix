{ pkgs, ... }:
{
    # packages for video acceleration TODO: ensure all
    hardware.opengl.extraPackages = with pkgs; [
        intel-media-driver
        libvdpau-va-gl
        intel-ocl
    ];
}
