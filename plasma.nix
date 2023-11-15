{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    armcord
    fastfetch
    google-chrome
    gparted
    vscode
  ];

  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    khelpcenter
  ];

  programs.git = {
    enable = true;
    config = {
      user = {
        email = "perm-iterate-0b@icloud.com";
	name = "Ali Rizvi";
	signingKey = "BCB5CEFDE22282F5";
      };
      commit = {
        gpgSign = true;
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  programs.gnupg = {
    agent = {
      enable = true;
      enableBrowserSocket = true;
      enableExtraSocket = true;
      enableSSHSupport = true;
    };
  };

  services.xserver = {
    enable = true;
    
    displayManager = {
      sddm.enable = true;
      defaultSession = "plasmawayland";
    };

    desktopManager = {
      plasma5.enable = true;
    };
  };
}
