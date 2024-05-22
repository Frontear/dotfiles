{ inputs, outputs, ... }: {
  imports = [ outputs.nixosModules.impermanence ];

  # System
  impermanence = { system.directories = [ "/etc/NetworkManager" ]; };

  networking = {
    useDHCP =
      false; # WARN: pretty sure this isn't needed but marking in-case it causes an issue.
    dhcpcd.enable = false; # NetworkManager uses its own

    hostFiles = [ "${inputs.stevenblack}/hosts" ];

    nameservers =
      [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];

    networkmanager = {
      enable = true;

      dns = "none"; # we use StevenBlack

      wifi.powersave = true;
    };
  };

  systemd.services."NetworkManager-wait-online".enable = false;
}
