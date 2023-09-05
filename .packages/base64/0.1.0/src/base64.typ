#let charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

/// Convert a number to a binary array and pad it.
///
/// Arguments:
/// - number: The number to convert.
/// - size: The size of the array. If given, the array will be padded with 0s.
///
/// Returns: The binary array.
#let bin(number, size: none) = {
  let result = while number > 0 {
    (calc.rem(number, 2),)
    number = calc.floor(number / 2);
  }

  if result == none { result = (0,) }
  if size != none and result.len() < size {
    result.push(((0,) * (size - result.len())));
  }

  return result.rev().flatten();
}

/// Convert a binary array to a number.
///
/// Arguments:
/// - array: The binary array to convert.
///
/// Returns: The number.
#let dec(array) = {
  array.enumerate().fold(0, (acc, (i, bit)) => {
    acc + bit * calc.pow(2, (array.len() - i - 1))
  })
}

/// Encodes the given data in base64 format.
///
/// Arguments:
/// - padding: Whether to pad the output with "=" characters.
/// - url: Whether to use URL-safe characters.
/// - data: The data to encode. Must be of type array, bytes, or string.
///
/// Returns: The encoded string.
#let encode(padding: true, url: false, data) = {
  let bytes = array(bytes(data))
  let bits = bytes.map(bin.with(size: 8)).flatten()
  let pad-amount = calc.rem(6 - calc.rem(bits.len(), 6), 6)

  if bytes.len() == 0 {
    return ""
  }

  let string = for i in range(0, bits.len(), step: 6) {
    let chunk = if bits.len() >= i + 6 {
      bits.slice(i, i + 6)
    } else {
      bits.slice(i) + ((0,) * pad-amount)
    }
    charset.at(dec(chunk))
  }

  if padding {
    string += range(int(pad-amount / 2)).map(_ => "=").join("")
  }

  if url {
    string = string.replace("+", "-").replace("/", "_")
  }

  string
}

/// Decodes the given base64 string.
///
/// URL safe characters are automatically converted to their standard
/// counterparts. Invalid characters are ignored. Invalid padding will
/// cause a panic, however, padding is optional.
///
/// Arguments:
/// - string: The string to decode.
///
/// Returns: The decoded bytes.
#let decode(string) = {
  let pad-amount-given = string.codepoints().filter(c => c == "=").len()

  string = string
    .replace("-", "+")
    .replace("_", "/")
    .replace("%3d", "")
    .replace("=", "")

  let bits = string.codepoints()
    .map(c => charset.position(c))
    .filter(n => n != none)
    .map(bin.with(size: 6))
    .flatten()

  let pad-amount = calc.rem(bits.len(), 8)
  if pad-amount > 0 {
    bits = bits.slice(0, -pad-amount)
  }

  if pad-amount-given > 0 and pad-amount-given != pad-amount / 2 {
    let expected = str(pad-amount / 2)
    let found = str(pad-amount-given)
    panic("invalid padding: expected " + expected + " but found " + found)
  }

  let byte-array = range(0, bits.len(), step: 8).map(i => {
    let chunk = bits.slice(i, i + 8)
    dec(chunk)
  })

  bytes(byte-array)
}
