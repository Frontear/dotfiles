{
    inputs,
    nixpkgs,
    ...
}:
let
    flakeChannelCompat = {
        # https://ayats.org/blog/channels-to-flakes
        nix = {
            nixPath = [ "nixpkgs=flake:nixpkgs" ];
            registry = {
                nixpkgs.flake = nixpkgs;
            };
        };
    };
    hosts = rec {
        _suffix = "3DT4F02";
        
        desktop = "DESKTOP-${_suffix}";
        laptop = "LAPTOP-${_suffix}";
    };
    username = "frontear";
in {
    "${hosts.laptop}" = nixpkgs.lib.nixosSystem {
        specialArgs = {
            inherit inputs username;
            hostname = "${hosts.laptop}";
        };
        modules = [
            ./laptop
            flakeChannelCompat
        ];
    };

    #"${hosts.desktop}" = nixpkgs.lib.nixosSystem {
    #    specialArgs = {
    #        inherit inputs username;
    #        hostname = "${hosts.desktop}"
    #    };
    #    modules = [
    #        ./desktop
    #        flakeChannelCompat
    #    ];
    #};
}
