{
  ...
}:
{
  config = {
    # Use `dbus-broker` as the implementation of D-Bus. The reasoning for this
    # is summarised well by Arch Linux.
    #
    # see: https://archlinux.org/news/making-dbus-broker-our-default-d-bus-daemon
    services.dbus.implementation = "broker";
  };
}