{ ... }: {
  # System
  environment.persistence."/nix/persist".users.frontear = {
    directories = [
      ".config/ArmCord"
    ];
  };

  # User
  home-manager.users.frontear = { pkgs, ... }: {
    home.packages = with pkgs; [
      armcord
    ];
  };
}