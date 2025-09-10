use std::env;
use std::error::Error;
use std::path::{ Path, PathBuf };

use std::fs;
use std::os::unix::fs::chown;
use std::os::unix::fs::MetadataExt;

fn create(src_acc: &PathBuf, dst_acc: &PathBuf) -> Result<(), Box<dyn Error>> {
  let src_meta = fs::metadata(src_acc)?;
  let src_prms = src_meta.permissions();

  // create an empty directory or file as needed.
  // obviously we know that all parent's will be directories
  // until the final stub, which can be either or, but this is
  // just easier to write out here so we don't need special
  // handling for the final entry.
  if src_meta.is_dir() { fs::create_dir_all(dst_acc)?; }
  if src_meta.is_file() { fs::File::create(dst_acc)?; }

  // synchronise permissions from the source to the target.
  chown(dst_acc, Some(src_meta.uid()), Some(src_meta.gid()))?;
  fs::set_permissions(dst_acc, src_prms)?;

  return Ok(());
}

// Accepts 3 arguments
//
//   $1   root path to the source that is referenced for permissions
//   $2   root path to the target that is created on
//   $3   path that exists on source, that must be made on target
//
// This program will create the path specified by $3 on the target root,
// and use the source as a reference for the type, owners, and modifiers
// of the file that will materialise on the target.
fn main() -> Result<(), Box<dyn Error>> {
  let args: Vec<_> = env::args().collect();

  let mut src_acc = PathBuf::from(&args[1]); // sourceRoot
  let mut dst_acc = PathBuf::from(&args[2]); // targetRoot

  // iteratively accumulate final path onto the roots.
  // all the while, synchronise permissions.
  for parent in Path::new(&args[3]).iter().skip(1) {
    src_acc.push(parent);
    dst_acc.push(parent);

    create(&src_acc, &dst_acc)?;
  }

  return Ok(());
}
