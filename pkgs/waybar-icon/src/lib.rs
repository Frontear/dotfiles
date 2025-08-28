use serde::Deserialize;
use waybar_cffi::{ InitInfo, Module };
use waybar_cffi::{ gtk, gtk::prelude::* };

#[derive(Deserialize)]
#[serde(rename_all = "kebab-case")]
struct Config {
  icon_name: String,
}

struct Icon;

impl Module for Icon {
  type Config = Config;

  fn init(info: &InitInfo, config: Config) -> Self {
    let root = info.get_root_widget();

    let g_box = gtk::Box::new(gtk::Orientation::Horizontal, 0);
    let g_image = gtk::Image::new();

    g_box.set_widget_name("icon");
    g_box.pack_start(&g_image, true, true, 0);

    root.add(&g_box);

    let g_theme = gtk::IconTheme::default().unwrap();
    if let Some(info) = g_theme.lookup_icon(&config.icon_name, 24, gtk::IconLookupFlags::FORCE_SVG) {
      let scaled_size = 28 * g_image.scale_factor();

      let pixbuf = gtk::gdk_pixbuf::Pixbuf::from_file_at_size(&info.filename().unwrap(), scaled_size, scaled_size).unwrap();
      let surface = pixbuf.create_surface::<gtk::gdk::Window>(g_image.scale_factor(), None).unwrap();

      g_image.set_from_surface(Some(&surface));
    }

    return Icon;
  }
}

waybar_cffi::waybar_module!(Icon);
