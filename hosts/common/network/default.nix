{
  inputs,
  ...
}: {
  # Use NetworkManager for managing network connections
  networking.networkmanager.enable = true;

  # Disable NetworkManager dns resolution and use Cloudflare's 1.1.1.1 dns
  networking.networkmanager.dns = "none";
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];

  # Use stevenblack's host files. Pulled from flakes.
  networking.hostFiles = [
    "${inputs.stevenblack.outPath}/hosts"
  ];

  # Persist /etc/NetworkManager, because this contains our connections
  impermanence.root.directories = [
    "/etc/NetworkManager"
  ];

  # Disable wait-online because I don't need to wait to be online before
  # getting the system running.
  systemd.services."NetworkManager-wait-online".enable = false;
}
