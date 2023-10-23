#import "unify.typ": num, qty, unit, numrange, qtyrange

// Set default parameters for all functions in this module.
//
// This is a convenience function that allows you to set the parameters for all
// functions in this module at once. It is equivalent to calling `with` on each
// function individually.
//
// Parameters:
// - product: The symbol to use for the exponent product.
// - decimal-sep: The decimal seperator.
// - group-sep: The seperator between digit groups.
// - delim: Delimiter between numbers in a range. Quotes must be escaped.
// - delim-space: Space between the numbers and the delimiter.
// - unit-space: Space between units.
// - per: How to format fractions. Can be "symbol", "fraction" or "slash".
//
// Returns:
// - num: A function that formats numbers.
// - qty: A function that formats quantities.
// - unit: A function that formats units.
// - numrange: A function that formats number ranges.
// - qtyrange: A function that formats quantity ranges.
#let with(
  product: "dot",
  decimal-sep: ".",
  group-sep: "thin",
  delim: "\"to\"",
  delim-space: "",
  unit-space: "thin",
  per: "symbol"
) = (
  num: num.with(
    product: product,
    decimal-sep: decimal-sep,
    group-sep: group-sep
  ),

  qty: qty.with(
    product: product,
    decimal-sep: decimal-sep,
    group-sep: group-sep,
    unit-space: unit-space,
    per: per
  ),

  unit: unit.with(
    unit-space: unit-space,
    per: per
  ),

  numrange: numrange.with(
    product: product,
    decimal-sep: decimal-sep,
    group-sep: group-sep,
    delim: delim,
    delim-space: delim-space
  ),

  qtyrange: qtyrange.with(
    product: product,
    decimal-sep: decimal-sep,
    group-sep: group-sep,
    delim: delim,
    delim-space: delim-space,
    unit-space: unit-space,
    per: per
  )
)
