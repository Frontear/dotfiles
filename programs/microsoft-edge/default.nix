{ pkgs, ... }: {
  # System
  environment.persistence."/nix/persist".users.frontear = {
    directories = [
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