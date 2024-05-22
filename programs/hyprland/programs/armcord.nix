{ outputs, ... }: {
  imports = [ outputs.nixosModules.impermanence ];

  # System
  impermanence = { user.directories = [ ".config/ArmCord" ]; };

  # User
  home-manager.users.frontear = { pkgs, ... }: {
    home.packages = with pkgs; [ armcord ];
  };
}
