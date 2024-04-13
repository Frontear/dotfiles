{ outputs, pkgs, ... }: {
  imports = [
    outputs.nixosModules.impermanence
  ];

  # System
  impermanence = {
    user.directories = [
      ".config/microsoft-edge"
      # TODO: persist sync somehow
    ];
  };

  # User
  home-manager.users.frontear = {
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