{ ... }:
{
    # set to cloudflare dns
    networking.nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
    ];

    # disable networkmanager dns resolution, so it uses the above
    networking.networkmanager.dns = "none";
}
