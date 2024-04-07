{ ... }: {
  # System
  environment.persistence."/nix/persist".users.frontear = {
    directories = [
      ".gnupg"
    ];
  };

  # User
  home-manager.users.frontear = { pkgs, ... }: {
    programs.gpg = {
      enable = true;

      # TODO: homedir

      mutableKeys = true;
      mutableTrust = true;
    };

    services.gpg-agent = {
      enable = true;

      enableSshSupport = true;

      pinentryPackage = pkgs.pinentry-tty;

      sshKeys = [
        "AF4BF6EE3E68FD7576667BE7D8A7CFA50BC8E9F2"
      ];
    };
  };
}