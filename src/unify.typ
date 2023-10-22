#import "format/number.typ": format-float, format-number, format-range
#import "format/unit.typ": format-unit, format-unit-short

// Regex pattern for a number.
//
// Includes the following captures:
// - 0: The value.
// - 1: The upper error.
// - 2: The lower error.
// - 3: The combined error.
// - 4: The exponent.
#let number-pattern = regex({
  "^"                                     // Start of string
  "([\+-]?\d+\.?\d*)?"                    // Value (optional)
  "(?:"                                   // Uncertainty (start)
    "(?:\+(\d+\.?\d*)-(\d+\.?\d*))"       // > Upper and lower
    "|"                                   // > or
    "(?:(?:(?:\+-)|(?:-\+))(\d+\.?\d*))"  // > Combined
  ")?"                                    // Uncertainty (end) (optional)
  "(?:[eE]([-\+]?\d+))?"                  // Exponent (optional)
  "$"                                     // End of string
})

// Parse a float-string with the above regex.
//
// Parameters:
// - value: String with the number.
//
// Returns:
// - value: String with the number.
// - exponent: String with the exponent.
// - upper: String with the upper error.
// - lower: String with the lower error.
#let parse-number(value) = {
  value = value.replace(",", ".").replace(" ", "")

  let match = value.match(number-pattern)
  assert.ne(match, none, message: "invalid number: " + value)

  // Assert that the given number is a valid float.
  let validate(string) = if string != none {
    let _ = float(string)
    string
  }

  let (value, upper, lower, combined, exponent) = match.captures
  
  // If the combined error is given, use it for both upper and lower.
  if combined != none {
    upper = combined
    lower = combined
  }

  // Strip leading plus signs.
  if value != none and value.first() == "+" {
    value = value.slice(1)
  }

  if exponent != none and exponent.first() == "+" {
    exponent = exponent.slice(1)
  }

  (
    value: validate(value),
    exponent: validate(exponent),
    upper: validate(upper),
    lower: validate(lower)
  )
}

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
  let number = parse-number(value)

  let result = format-number(
    number,
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
    space: unit-space,
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
  let number = parse-number(value)

  let result = format-number(
    number,
    product: product,
    decimal-sep: decimal-sep,
    group-sep: group-sep
  )

  if raw-unit {
    result += unit-space + " upright(" + unit + ")"
  } else {
    result += format-unit(unit, space: unit-space, per: per)
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
  let lower = parse-number(lower)
  let upper = parse-number(upper)

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
  let lower = parse-number(lower)
  let upper = parse-number(upper)

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

  if raw-unit {
    result += unit-space + " upright(" + unit + ")"
  } else {
    result += format-unit(unit, space: unitspace, per: per)
  }

  eval(mode: "math", result)
}
