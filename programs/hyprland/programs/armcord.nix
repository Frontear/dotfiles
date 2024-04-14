{ outputs, config, ... }: {
  imports = [
    outputs.nixosModules.impermanence
    outputs.nixosModules.main-user
  ];

  # System
  impermanence = {
    user.directories = [
      ".config/ArmCord"
    ];
  };

  # User
  home-manager.users.${config.main-user.name} = { pkgs, ... }: {
    home.packages = with pkgs; [
      armcord
    ];
  };
}