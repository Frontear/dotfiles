{ outputs, config, pkgs, ... }: {
  imports = [
    outputs.nixosModules.impermanence
    outputs.nixosModules.main-user
  ];

  # System
  impermanence = {
    user.directories = [
      ".config/microsoft-edge"
      # TODO: persist sync somehow
    ];
  };

  # User
  home-manager.users.${config.main-user.name} = {
    programs.chromium = {
      enable = true;
      package = pkgs.microsoft-edge;

      dictionaries = with pkgs.hunspellDictsChromium; [
        en_US
      ];

      # TODO: extensions?
    };
  };
}