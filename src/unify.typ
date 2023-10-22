#import "format.typ": format-float, format-number, format-range, format-unit, format-unit-short

#let re-num = regex("^(-?\d+(\.|,)?\d*)?(((\+(\d+(\.|,)?\d*)-(\d+(\.|,)?\d*)))|((((\+-)|(-\+))(\d+(\.|,)?\d*))))?(e([-\+]?\d+))?$")

// Format a number.
//
// Parameters:
// - value: String with the number.
// - thousandsep: The seperator between the thousands of the float.
#let num(
  value,
  thousandsep: "thin"
) = {
  value = str(value).replace(" ", "")//.replace(",", ".")

  let match-value = value.match(re-num)
  assert.ne(match-value, none, message: "invalid number: " + value)
  let captures-value = match-value.captures

  let upper = none
  let lower = none
  if captures-value.at(14) != none {
    upper = captures-value.at(14)
    lower = none
  } else {
    upper = captures-value.at(5)
    lower = captures-value.at(7)
  }

  let formatted = format-num(
    captures-value.at(0),
    exponent: captures-value.at(17),
    upper: upper,
    lower: lower,
    thousandsep: thousandsep
  )

  formatted = "$" + formatted + "$"
  eval(formatted)
}

// Format a unit.
//
// Parameters:
// - unit: String containing the unit.
// - space: Space between units.
// - per: Whether to format the units after `per` or `/` with a fraction or exponent.
#let unit(
  unit,
  space: "thin",
  per: "symbol"
) = {
  let formatted-unit = ""
  formatted-unit = format-unit(unit, space: space, per: per)

  let formatted = "$" + formatted-unit + "$"
  eval(formatted)
}

// Format a quantity (i.e. number with a unit).
//
// Parameters:
// - value: String containing the number.
// - unit: String containing the unit.
// - rawunit: Whether to transform the unit or keep the raw string.
// - space: Space between units.
// - thousandsep: The seperator between the thousands of the float.
// - per: Whether to format the units after `per` or `/` with a fraction or exponent.
#let qty(
  value,
  unit,
  rawunit: false,
  space: "thin",
  thousandsep: "thin",
  per: "symbol"
) = {
  value = str(value).replace(" ", "")

  let match-value = value.match(re-num)
  assert.ne(match-value, none, message: "invalid number: " + value)
  let captures-value = match-value.captures

  let upper = none
  let lower = none
  if captures-value.at(14) != none {
    upper = captures-value.at(14)
    lower = none
  } else {
    upper = captures-value.at(5)
    lower = captures-value.at(7)
  }

  let formatted-value = format-num(
    captures-value.at(0),
    exponent: captures-value.at(17),
    upper: upper,
    lower: lower,
    thousandsep: thousandsep
  )

  let formatted-unit = ""
  if rawunit {
    formatted-unit = space + unit
  } else {
    formatted-unit = format-unit(unit, space: space, per: per)
  }

  let formatted = "$" + formatted-value + formatted-unit + "$"
  eval(formatted)
}

// Format a range.
//
// Parameters:
// - (lower, upper): Strings containing the numbers.
// - delimiter: Symbol between the numbers.
// - space: Space between the numbers and the delimiter.
// - thousandsep: The seperator between the thousands of the float.
#let numrange(
  lower, 
  upper,
  delimiter: "-",
  space: "thin",
  thousandsep: "thin"
) = {
  lower = str(lower).replace(" ", "")
  let match-lower = lower.match(re-num)
  assert.ne(match-lower, none, message: "invalid lower number: " + lower)
  let captures-lower = match-lower.captures

  upper = str(upper).replace(" ", "")
  let match-upper = upper.match(re-num)
  assert.ne(match-upper, none, message: "invalid upper number: " + upper)
  let captures-upper = match-upper.captures

  let formatted = format-range(
    captures-lower.at(0),
    captures-upper.at(0),
    exponent-lower: captures-lower.at(17),
    exponent-upper: captures-upper.at(17),
    delimiter: delimiter,
    thousandsep: thousandsep,
    space: space,
  )

  formatted = "$" + formatted + "$"
  eval(formatted)
}

// Format a range with a unit.
//
// Parameters:
// - (lower, upper): Strings containing the numbers.
// - unit: String containing the unit.
// - rawunit: Whether to transform the unit or keep the raw string.
// - delimiter: Symbol between the numbers.
// - space: Space between the numbers and the delimiter.
// - unitspace: Space between units.
// - thousandsep: The seperator between the thousands of the float.
// - per: Whether to format the units after `per` or `/` with a fraction or exponent.
#let qtyrange(
  lower,
  upper,
  unit,
  rawunit: false,
  delimiter: "-",
  space: "",
  unitspace: "thin",
  thousandsep: "thin",
  per: "symbol"
) = {
  lower = str(lower).replace(" ", "")
  let match-lower = lower.match(re-num)
  assert.ne(match-lower, none, message: "invalid lower number: " + lower)
  let captures-lower = match-lower.captures

  upper = str(upper).replace(" ", "")
  let match-upper = upper.match(re-num)
  assert.ne(match-upper, none, message: "invalid upper number: " + upper)
  let captures-upper = match-upper.captures

  let formatted-value = format-range(
    captures-lower.at(0),
    captures-upper.at(0),
    exponent-lower: captures-lower.at(17),
    exponent-upper: captures-upper.at(17),
    delimiter: delimiter,
    space: space,
    thousandsep: thousandsep,
    force-parentheses: true
  )

  let formatted-unit = ""
  if rawunit {
    formatted-unit = space + unit
  } else {
    formatted-unit = format-unit(unit, space: unitspace, per: per)
  }

  let formatted = "$" + formatted-value + formatted-unit + "$"
  eval(formatted)
}
