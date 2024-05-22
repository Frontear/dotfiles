{ ... }: {
  # System
  programs.light = { enable = true; };
  users.extraUsers.frontear.extraGroups = [ "video" ];
}
