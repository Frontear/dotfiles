{ nixos-wsl, ... }: ({ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    ../../nmodules/files.nix

    nixos-wsl.nixosModules.default
  ];

  file."/var/test" = {
    impure = true;

    content = ''
      This is a test file created at /var/test.
      It can be modified, as it has been declared with "impure = true;"
    '';
  };

  frontear.programs.terminal.enable = true;

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  wsl = {
    enable = true;
    defaultUser = "frontear";
    nativeSystemd = true;
    useWindowsDriver = true;
  };

  environment.systemPackages = with pkgs; [ yt-dlp ];
})
