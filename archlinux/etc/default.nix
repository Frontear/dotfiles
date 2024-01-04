{
  ...
}: {
  imports = [
    ./hosts.nix
    ./issue.nix
    ./ly
    ./makepkg.nix
    ./mke2fs.nix
    ./mkinitcpio.conf.d
    ./modprobe.d
    ./modules-load.d
    ./NetworkManager
    ./pacman.nix
    ./pacman.d
    ./polkit-1
    ./sudoers.d
    ./sysctl.d
    #./systemd
    ./tmpfiles.d
    #./udev
    ./updatedb.nix
    ./xdg
  ];
}
