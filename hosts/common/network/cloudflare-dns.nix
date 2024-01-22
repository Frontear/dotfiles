{ ... }: {
  networking = {
    # Setup the usage of Cloudflare's 1.1.1.1 DNS servers.
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];

    # Need to disable NetworkManager's internal DNS resolution, since it will take priority
    # over the nameservers we defined above, which defeats the point of having them.
    networkmanager.dns = "none";
  };
}
