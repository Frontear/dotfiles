{
  ...
}: {
  imports = [
    ./99-zram.nix
    ./pci_powersave.nix
    ./scsi_powersave.nix
    ./usb_powersave.nix
  ];
}
