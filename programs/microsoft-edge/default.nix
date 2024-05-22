{ outputs, pkgs, ... }: {
  imports = [ outputs.nixosModules.impermanence ];

  # System
  impermanence = {
    user.directories = [
      ".config/microsoft-edge"
      # TODO: persist sync somehow
    ];
  };

  users.extraUsers.frontear.packages = with pkgs; [ microsoft-edge ];
}
