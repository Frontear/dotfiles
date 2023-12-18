{
    config,
    lib,
    ...
}:
let
    inherit (lib) mdDoc mkIf mkOption types;
in {
    options.boot.fast = mkOption {
        type = types.bool;
        description = mdDoc ''
        Switches the initrd compressor to one that decompress very fast in exchange for poorer compression (larger image sizes on disk).
        '';
    };

    config = mkIf config.boot.fast {
        boot.initrd.compressor = "cat";
    };
}
