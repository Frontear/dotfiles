use std::ffi::c_int;

mod rgb {
  pub fn from_u32(rgb: u32) -> (u8, u8, u8) {
    return (
      ((rgb & 0xff0000) >> 16) as u8,
      ((rgb & 0x00ff00) >> 8)  as u8,
      ((rgb & 0x0000ff) >> 0)  as u8,
    );
  }

  pub fn to_u32((r, g, b): (u8, u8, u8)) -> u32 {
    return (r as u32) << 16 | (g as u32) << 8 | (b as u32) << 0;
  }
}

#[unsafe(no_mangle)]
pub extern "C" fn swaylock_pixel(pix: u32, _: c_int, _: c_int, _: c_int, _: c_int) -> u32 {
  let (r, g, b) = rgb::from_u32(pix);
  let mut hsl = hsl::HSL::from_rgb(&[r, g, b]);

  hsl.l *= 0.7; // dim to 70%

  return rgb::to_u32(hsl.to_rgb());
}