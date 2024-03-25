{ ... }: {
  # System
  environment.persistence."/nix/persist".users.frontear = {
    directories = [
      ".gnupg"
    ];
  };

  programs.gnupg.agent.enable = true; # This sets pinentry automatically

  # User
  home-manager.users.frontear = {
    programs.gpg = {
      enable = true;

      # TODO: homedir

      mutableKeys = true;
      mutableTrust = true;
    };

    services.gpg-agent = {
      enable = true;

      enableSshSupport = true;

      sshKeys = [
        "AF4BF6EE3E68FD7576667BE7D8A7CFA50BC8E9F2"
      ];
    };
  };
}