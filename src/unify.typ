#import "format/number.typ": format-number, format-range
#import "format/unit.typ": format-unit

// Format a number.
//
// Parameters:
// - value: String containing the number.
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
    value,
    product: product,
    decimal-sep: decimal-sep,
    group-sep: group-sep
  )

  eval(mode: "math", result)
}

// Format a unit.
//
// Parameters:
// - unit: String containing the unit.
// - unit-space: Space between units.
// - per: How to format unit fractions.
#let unit(
  unit,
  unit-space: "thin",
  per: "symbol"
) = {
  let result = format-unit(
    unit,
    unit-space: unit-space,
    per: per
  )

  eval(mode: "math", result)
}

// Format a quantity (i.e. number with a unit).
//
// Parameters:
// - value: String containing the number.
// - unit: String containing the unit.
// - product: The symbol to use for the exponent product.
// - decimal-sep: The decimal seperator.
// - group-sep: The seperator between digit groups.
// - raw-unit: Whether to transform the unit or keep the raw string.
// - unit-space: Space between units.
// - per: How to format unit fractions.
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
    value,
    product: product,
    decimal-sep: decimal-sep,
    group-sep: group-sep,
    force-parentheses: true,
  )

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
// - lower: String containing the lower bound.
// - upper: String containing the upper bound.
// - product: The symbol to use for the exponent product.
// - decimal-sep: The decimal seperator.
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
    lower,
    upper,
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
// - lower: String containing the lower bound.
// - upper: String containing the upper bound.
// - unit: String containing the unit.
// - product: The symbol to use for the exponent product.
// - decimal-sep: The decimal seperator.
// - group-sep: The seperator between digit groups.
// - delim: Symbol between the numbers.
// - delim-space: Space between the numbers and the delimiter.
// - raw-unit: Whether to transform the unit or keep the raw string.
// - unit-space: Space between units.
// - per: How to format unit fractions.
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
    lower,
    upper,
    product: product,
    decimal-sep: decimal-sep,
    group-sep: group-sep,
    delim: delim,
    delim-space: delim-space,
    force-parentheses: true,
  )

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
