#import "number.typ": format-number, format-range
#import "unit.typ": format-unit

// Convert the argument to a string.
//
// The argument can be of type `int`, `float`, `str`, or `content`.
//
// If the argument is a `content` object, it can be a `math.attach`,
// `math.frac` or `text` element, or a sequence of these.
#let to-string(body) = {
  if type(body) == str {
    // Strings
    return body.replace("\u{2212}", "-")
  } else if type(body) in (int, float) {
    // Numbers
    return str(body)
  } else if type(body) == content {
    if body.func() == math.attach {
      // Exponents
      let base = to-string(body.base)
      let exponent = to-string(body.t)
      return base + "^" + exponent
    } else if body.func() == math.frac {
      // Fractions
      let num = to-string(body.num)
      let denom = to-string(body.denom)
      return num + "/" + denom
    } else if body.has("children") {
      // Sequences
      return body.children.map(to-string).join("")
    } else if body.has("text") {
      // Text
      return to-string(body.text)
    } else if body == [ ] {
      // Space
      return " "
    }
  }

  panic("cannot convert argument to string")
}

// Format a number.
//
// Parameters:
// - value: The number.
// - product: The symbol to use for the exponent product.
// - decimal-sep: The decimal seperator.
// - group-sep: The seperator between digit groups.
#let num(
  value,
  product: "dot",
  decimal-sep: ".",
  group-sep: "thin"
) = {
  let result = format-number(
    to-string(value),
    product: product,
    decimal-sep: decimal-sep,
    group-sep: group-sep
  )

  eval(mode: "math", result)
}

// Format a unit.
//
// Parameters:
// - unit: The unit.
// - unit-space: Space between units.
// - per: How to format fractions.
#let unit(
  unit,
  unit-space: "thin",
  per: "symbol"
) = {
  let result = format-unit(
    to-string(unit),
    unit-space: unit-space,
    per: per
  )

  eval(mode: "math", result)
}

// Format a quantity (i.e. number with a unit).
//
// Parameters:
// - value: The number.
// - unit: The unit.
// - product: The symbol to use for the exponent product.
// - decimal-sep: The decimal seperator.
// - group-sep: The seperator between digit groups.
// - raw-unit: Whether to transform the unit or keep the raw string.
// - unit-space: Space between units.
// - per: How to format fractions.
#let qty(
  value,
  unit,
  product: "dot",
  decimal-sep: ".",
  group-sep: "thin",
  raw-unit: false,
  unit-space: "thin",
  per: "symbol"
) = {
  let result = format-number(
    to-string(value),
    product: product,
    decimal-sep: decimal-sep,
    group-sep: group-sep,
    follows-unit: true,
  )

  unit = to-string(unit)
  result += " " + if raw-unit {
    unit-space + " upright(" + unit + ")"
  } else {
    format-unit(
      unit,
      unit-space: unit-space,
      per: per,
      prefix-space: true
    )
  }

  eval(mode: "math", result)
}

// Format a range.
//
// Parameters:
// - lower: The lower bound.
// - upper: The upper bound.
// - product: The symbol to use for the exponent product.
// - decimal-sep: The decimal separator.
// - group-sep: The seperator between digit groups.
// - delim: Symbol between the numbers.
// - delim-space: Space between the numbers and the delimiter.
#let numrange(
  lower, 
  upper,
  product: "dot",
  decimal-sep: ".",
  group-sep: "thin",
  delim: "\"to\"",
  delim-space: "",
) = {
  let result = format-range(
    to-string(lower),
    to-string(upper),
    product: product,
    decimal-sep: decimal-sep,
    group-sep: group-sep,
    delim: delim,
    delim-space: delim-space
  )

  eval(mode: "math", result)
}

// Format a range with a unit.
//
// Parameters:
// - lower: The lower bound.
// - upper: The upper bound.
// - unit: The unit.
// - product: The symbol to use for the exponent product.
// - decimal-sep: The decimal seperator.
// - group-sep: The seperator between digit groups.
// - delim: Symbol between the numbers.
// - delim-space: Space between the numbers and the delimiter.
// - raw-unit: Whether to transform the unit or keep the raw string.
// - unit-space: Space between units.
// - per: How to format fractions.
#let qtyrange(
  lower,
  upper,
  unit,
  product: "dot",
  decimal-sep: ".",
  group-sep: "thin",
  delim: "\"to\"",
  delim-space: "",
  raw-unit: false,
  unit-space: "thin",
  per: "symbol"
) = {
  let result = format-range(
    to-string(lower),
    to-string(upper),
    product: product,
    decimal-sep: decimal-sep,
    group-sep: group-sep,
    delim: delim,
    delim-space: delim-space,
    follows-unit: true,
  )

  unit = to-string(unit)
  result += " " + if raw-unit {
    unit-space + " upright(" + unit + ")"
  } else {
    format-unit(
      unit,
      unit-space: unit-space,
      per: per,
      prefix-space: true
    )
  }

  eval(mode: "math", result)
}
