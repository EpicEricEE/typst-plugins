#let lib = plugin("qr.wasm")

/// Create a QR code from the given data.
///
/// Arguments:
/// - format: The format of the image. Must be one of "png" or "svg". Default: "svg".
/// - margin: The margin around the QR code in units of modules. Default: 4.
/// - fill: The color of the QR code. Default: black.
/// - image-args: Additional arguments to pass to the image constructor.
/// - data: The data to encode. Must be of type array, bytes, or string.
///
/// Returns: The QR code as an image.
#let create(
  format: "svg",
  margin: 4,
  fill: black,
  ..image-args,
  data
) = {
  if margin == none { margin = 0 }

  // We can only pass byte arrays to the WASM module.
  // To keep things simple, we limit it to one byte.
  assert(0 <= margin and margin <= 255, message: "margin must be between 0 and 255")
  assert(format in ("png", "svg"), message: "format must be either \"png\" or \"svg\"")
  assert(type(fill) == color, message: "fill must be a color")
  
  let qr-args = (
    bytes(data),
    bytes((margin,)),
    bytes(rgb(fill).components().map(ratio => int(ratio/100% * 255)))
  )

  let image-data = if format == "png" {
    lib.png(..qr-args)
  } else {
    str(lib.svg(..qr-args))
  }

  image.decode(
    image-data,
    format: format,
    ..image-args
  )
}
