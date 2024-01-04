{
  ...
}: {
  imports = [
    ./20-quiet-printk.nix
    ./99-vm-zram.nix
    ./kernel-nmi-watchdog.nix
    ./vm-dirty.nix
    ./vm-dirty-writeback.nix
    ./vm-laptop.nix
    ./vm-vfs-cache.nix
  ];
}
