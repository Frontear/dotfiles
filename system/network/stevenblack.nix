{ ... }:
{
    # uses stevenblack hosts file
    networking.stevenblack = {
        enable = true;
        block = [ "fakenews" "gambling" "porn" "social" ];
    };
}
