// Format a float (or integer).
//
// Parameters:
// - value: The float to format.
// - decimal-sep: The decimal separator.
// - group-sep: The seperator between digit groups.
#let format-float(
  value,
  decimal-sep: ".",
  group-sep: "thin"
) = {
  value = str(value)

  let split = value.split(".")
  let int-part = split.at(0)
  let dec-part = split.at(1, default: none)

  let result = ""
  
  // Append integer part
  let int-list = int-part.clusters()
  result += int-list.remove(0)
  for (i, digit) in int-list.enumerate() {
    if calc.rem(int-list.len() - i, 3) == 0 {
      result += " " + group-sep + " "
    }
    result += digit
  }

  // Append decimal part
  if dec-part != none {
    result += decimal-sep

    let dec-list = dec-part.clusters()
    for (i, digit) in dec-list.enumerate() {
      if i != 0 and calc.rem(i, 3) == 0 {
        result += " " + group-sep + " "
      }
      result += digit
    }
  }

  result
    .replace(",", ",#h(0pt)")
    .replace(".", ".#h(0pt)")
}

// Format a number.
//
// Paramaters:
// - number: The number.
// - product: The symbol to use for the exponent product.
// - decimal-sep: The decimal separator.
// - group-sep: The seperator between digit groups.
// - force-parentheses: Whether to force parentheses around the number.
#let format-number(
  number,
  product: "dot",
  decimal-sep: ".",
  group-sep: "thin",
  force-parentheses: false
) = {
  let format-float = format-float.with(
    decimal-sep: decimal-sep,
    group-sep: group-sep
  )

  let result = ""

  // Append main value
  if number.value != none {
    result += format-float(number.value)
  }

  // Append uncertainties
  if number.upper != none and number.lower != none {
    if number.upper != number.lower {
      result += "^(+" + format-float(number.upper) + ")"
      result += "_(-" + format-float(number.lower) + ")"
    } else {
      result += " plus.minus " + format-float(number.upper)
    }
  } else if number.upper != none {
    result += " plus.minus " + format-float(number.upper)
  } else if number.lower != none {
    result += " plus.minus " + format-float(number.lower)
  }

  // Wrap in brackets if necessary
  let parentheses = force-parentheses
  if not parentheses and number.exponent != none and number.value != none {
    parentheses = number.upper != none or number.lower != none
  }
  if parentheses {
    result = "lr((" + result + "))"
  }

  // Append exponent
  if number.exponent != none {
    if number.value != none {
      result += " " + product + " "
    }
    result += "10^(" + str(number.exponent) + ")"
  }

  result
}

// Format a range.
//
// Parameters:
// - lower: The upper number.
// - upper: The lower number.
// - product: The symbol to use for the exponent product.
// - decimal-sep: The decimal separator.
// - group-sep: The seperator between digit groups.
// - delim: Symbol between the numbers.
// - delim-space: Space between the numbers and the delimiter.
// - force-parentheses: Whether to force parentheses around the range.
#let format-range(
  lower,
  upper,
  product: "dot",
  decimal-sep: ".",
  group-sep: "thin",
  delim: "-",
  delim-space: "thin",
  force-parentheses: false,
) = {
  let format-float = format-float.with(
    decimal-sep: decimal-sep,
    group-sep: group-sep
  )

  let result = ""

  // Append lower value (and exponent)
  result += format-float(lower.value)
  if lower.exponent != upper.exponent and lower.exponent != none {
    if lower.value != none {
      result += " " + product + " "
    }
    result += " 10^(" + str(lower.exponent) + ")"
  }

  // Append delimiter
  result += " " + delim-space + " " + delim + " " + delim-space + " "
  
  // Append upper value (and exponent)
  result += format-float(upper.value)
  if lower.exponent != upper.exponent and upper.exponent != none {
    if upper.value != none {
      result += " " + product + " "
    }
    result += "10^(" + str(upper.exponent) + ")"
  }

  // Wrap in brackets and append common exponent
  if lower.exponent == upper.exponent and lower.exponent != none {
    result = "lr((" + result + "))"
    result += " " + product + " 10^(" + str(lower.exponent) + ")"
  } else if force-parentheses {
    result = "lr((" + result + "))"
  }

  result
}
