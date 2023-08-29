#let lib = plugin("base64.wasm")

/// Encodes the given data in base64 format.
///
/// Arguments:
/// - data: The data to encode. Must be a string, array, or bytes.
///
/// Returns: The encoded data as string.
#let encode(data) = {
  str(lib.encode(bytes(data)))
}

/// Decodes the given base64 string.
///
/// Arguments:
/// - data: The string to decode.
///
/// Returns: The decoded data as bytes.
#let decode(data) = {
  lib.decode(bytes(data))
}
