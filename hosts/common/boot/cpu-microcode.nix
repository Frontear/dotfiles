{ ... }: {
  # Updates the CPU microcode by leveraging a hardware-configuration.nix entry.
  # In hardware-configuration.nix, there is an entry:
  #
  # hardware.cpu.<intel/amd>.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  #
  # Therefore, we can leverage that and use the configuration entry for it.
  hardware.enableRedistributableFirmware = true;
}
