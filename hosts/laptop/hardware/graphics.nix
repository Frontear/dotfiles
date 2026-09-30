{
  lib,
  pkgs,
  ...
}:
let
  # Helper script to unbind all detected VFs from `udev`, and reload them using
  # the `vfio-pci` driver instead of the native display driver.
  #
  # see: https://github.com/strongtz/i915-sriov-dkms/blob/c613c76e2e7023b1617bed346b9d35bf871fb958/docs/block-vfs.md
  rebindToVFIO = pkgs.writeShellScript "gpu-vf-rebind" ''
    modprobe vfio-pci

    echo "$PCI_SLOT_NAME" > "/sys/bus/pci/devices/$PCI_SLOT_NAME/driver/unbind"
    echo "vfio-pci" > "/sys/bus/pci/devices/$PCI_SLOT_NAME/driver_override"
    echo "$PCI_SLOT_NAME" > "/sys/bus/pci/drivers/vfio-pci/bind"
  '';
in {
  config = {
    # Remove the detected `i915` from here, since we are using `xe` instead.
    #
    # TODO: should I regenerate facter.json?
    hardware.facter.detected.boot.graphics.kernelModules = lib.mkForce [];

    # Use the `xe` driver for native SR-IOV support.
    hardware.intelgpu = {
      driver = "xe";
    };

    # Force the `xe` driver on my GPU.
    boot.extraModprobeConfig = ''
      options i915  force_probe=!9a49
      options xe    force_probe=9a49
    '';

    # Enable VFIO modules to passthrough the Intel VFs.
    boot.initrd.kernelModules = lib.mkBefore [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];

    # Enable IOMMU for virtualization support.
    #
    # TODO: for a long while now, I didn't have this on and it didn't affect
    # anything. Why is that? Was it enabling itself? Is it not needed?
    boot.kernelParams = [
      "intel_iommu=on"
    ];

    # Hide the VFs from the host system to prevent weird attempts by the
    # graphical session to use it.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:00:02.1", ATTR{vendor}=="0x8086", ATTR{device}=="0x9a49", DRIVER!="vfio-pci", RUN+="${rebindToVFIO}"
    '';

    # Expose 1 VF for use by a virtual machine. Can be changed at runtime.
    systemd.tmpfiles.rules = [
      "w /sys/devices/pci0000:00/0000:00:02.0/sriov_numvfs - - - - 1"
    ];
  };
}