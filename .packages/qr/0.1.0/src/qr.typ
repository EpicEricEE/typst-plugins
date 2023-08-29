#let lib = plugin("qr.wasm")

#let create(
  format: "png",
  width: none,
  height: none,
  alt: none,
  fit: none,
  data
) = {
  if format not in ("png", "svg") {
    panic("format must be png or svg")
  }

  let args = {}
  if width != none { args["width"] = width }
  if height != none { args["height"] = height }
  if alt != none { args["alt"] = alt }
  if fit != none { args["fit"] = fit }
  
  let data = if format == "png" {
    lib.png(bytes(data))
  } else {
    str(lib.svg(bytes(data)))
  }

  image.decode(data, format: format, ..args)
}
