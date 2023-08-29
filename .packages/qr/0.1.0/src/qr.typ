#let lib = plugin("qr.wasm")

/// Create a QR code from the given data.
///
/// Arguments:
/// - format: The format of the image. Either "png" or "svg".
/// - width: The width of the image.
/// - height: The height of the image.
/// - alt: A text describing the image.
/// - fit: How the image should adjust itself to a given area. One of "cover", "contain", or "stretch".
/// - margin: The margin around the QR code in units of modules. Default: 4.
/// - data: The data to encode.
///
/// Returns: The QR code as an image.
#let create(
  format: "png",
  width: none,
  height: none,
  alt: none,
  fit: none,
  margin: 4,
  data
) = {
  if margin == none { margin = 0 }

  // We can only pass byte arrays to the WASM module.
  // To keep things simple, we limit it to one byte.
  assert(margin <= 255, message: "margin must be less than 256")
  assert(format in ("png", "svg"), message: "format must be either \"png\" or \"svg\"")

  let args = (:)
  if width != none { args.insert("width", width) }
  if height != none { args.insert("height", height) }
  if alt != none { args.insert("alt", alt) }
  if fit != none { args.insert("fit", fit) }
  
  let data = if format == "png" {
    lib.png(bytes(data), bytes((margin,)))
  } else {
    str(lib.svg(bytes(data), bytes((margin,))))
  }

  image.decode(data, format: format, ..args)
}
