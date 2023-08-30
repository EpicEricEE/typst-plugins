#let lib = plugin("base64.wasm")

/// Encodes the given data in base64 format.
///
/// Arguments:
/// - data: The data to encode. Must be of type array, bytes, or string.
///
/// Returns: The encoded string.
#let encode(data) = {
  str(lib.encode(bytes(data)))
}

/// Decodes the given base64 string.
///
/// Arguments:
/// - string: The string to decode.
///
/// Returns: The decoded bytes.
#let decode(string) = {
  lib.decode(bytes(string))
}
