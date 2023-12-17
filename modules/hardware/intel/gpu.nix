{
    pkgs,
    ...
}: {
    # TODO: move modprobe configs for intel gpu here from powersaving
    hardware.opengl.enable = true;
    hardware.opengl.extraPackages = with pkgs; [
        intel-media-driver
        intel-ocl
        intel-vaapi-driver
        libvdpau-va-gl
        vaapiVdpau
    ];
}
