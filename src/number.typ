// Regex pattern for a number with plus/minus uncertainty.
//
// Returns the following captures:
// - 0: The value.
// - 1: The upper error.
// - 2: The lower error.
// - 3: The combined error.
// - 4: The exponent.
#let number-pattern-plusminus = regex({
  "^"                               // Start of string
  "([\+-]?\d+\.?\d*)?"              // Value (optional)
  "(?:"                             // Uncertainty (start)
    "(?:\+(\d+\.?\d*)-(\d+\.?\d*))" // > Upper and lower
    "|"                             // > or
    "(?:(?:±|\+-|-\+)(\d+\.?\d*))"  // > Combined
  ")?"                              // Uncertainty (end) (optional)
  "(?:[eE]([-\+]?\d+))?"            // Exponent (optional)
  "$"                               // End of string
})

// Regex pattern for a number with last-digits uncertainty.
//
// Returns the following captures:
// - 0: The value.
// - 1: The uncertainty.
// - 2: The exponent.
#let number-pattern-parentheses = regex({
  "^"                    // Start of string
  "([\+-]?\d+\.?\d*)"    // Value
  "(?:\((\d+)\))?"       // Uncertainty
  "(?:[eE]([-\+]?\d+))?" // Exponent (optional)
  "$"                    // End of string
})

// Parse a number string.
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

  let match = value.match(number-pattern-plusminus)
  if match == none {
    match = value.match(number-pattern-parentheses)
  }

  assert.ne(match, none, message: "invalid number: " + value)
  let (value, ..rest, exponent) = match.captures

  // Strip leading plus signs.
  if value != none {
    value = value.trim("+", at: start)
  }
  if exponent != none {
    exponent = exponent.trim("+", at: start)
  }
  
  let (upper, lower) = if rest.len() == 3 {
    // Plus/minus uncertainty.
    let (upper, lower, combined) = rest
    if combined != none {
      (combined, combined)
    } else {
      (upper, lower)
    }
  } else {
    // Parentheses uncertainty.
    let error = rest.first()
    let len = value.replace(".", "").len()
    if error.len() < len {
      error = "0" * (len - error.len()) + error
    }

    let decimal-pos = value.position(".")
    if decimal-pos != none {
      decimal-pos = value.len() - decimal-pos - 1 // Position from end
      error = error.slice(0, -decimal-pos) + "." + error.slice(-decimal-pos)
    }

    error = error.replace(regex("^0+(\d+)"), m => m.captures.first())
    (error, error)
  }

  (
    value: value,
    exponent: exponent,
    upper: upper,
    lower: lower
  )
}

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
  
  // Append integer part.
  let int-list = int-part.clusters()
  result += int-list.remove(0)
  for (i, digit) in int-list.enumerate() {
    if calc.rem(int-list.len() - i, 3) == 0 {
      result += " " + group-sep + " "
    }
    result += digit
  }

  // Append decimal part.
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
// Parameters:
// - string: The string containing the number.
// - product: The symbol to use for the exponent product.
// - decimal-sep: The decimal separator.
// - group-sep: The seperator between digit groups.
// - follows-unit: Whether this number is followed by a unit.
#let format-number(
  string,
  product: "dot",
  decimal-sep: ".",
  group-sep: "thin",
  follows-unit: false
) = {
  let number = parse-number(string)
  let format-float = format-float.with(
    decimal-sep: decimal-sep,
    group-sep: group-sep
  )

  let result = ""

  // Append main value.
  if number.value != none {
    result += format-float(number.value)
  }

  // Append uncertainties.
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

  // Wrap in brackets if necessary.
  let uncertain = number.upper != none or number.lower != none
  let exponent-product = number.value != none and number.exponent != none
  let parentheses = uncertain and (follows-unit or exponent-product)
  if parentheses {
    result = "lr((" + result + "))"
  }

  // Append exponent.
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
// - lower: The string containing the lower bound.
// - upper: The string containing the upper bound.
// - product: The symbol to use for the exponent product.
// - decimal-sep: The decimal separator.
// - group-sep: The seperator between digit groups.
// - delim: Symbol between the numbers.
// - delim-space: Space between the numbers and the delimiter.
// - follows-unit: Whether this range is followed by a unit.
#let format-range(
  lower,
  upper,
  product: "dot",
  decimal-sep: ".",
  group-sep: "thin",
  delim: "-",
  delim-space: "thin",
  follows-unit: false,
) = {
  let lower = parse-number(lower)
  let upper = parse-number(upper)
  let format-float = format-float.with(
    decimal-sep: decimal-sep,
    group-sep: group-sep
  )

  let result = ""

  // Append lower value (and exponent).
  result += format-float(lower.value)
  if lower.exponent != upper.exponent and lower.exponent != none {
    if lower.value != none {
      result += " " + product + " "
    }
    result += " 10^(" + str(lower.exponent) + ")"
  }

  // Append delimiter.
  result += " " + delim-space + " " + delim + " " + delim-space + " "
  
  // Append upper value (and exponent).
  result += format-float(upper.value)
  if lower.exponent != upper.exponent and upper.exponent != none {
    if upper.value != none {
      result += " " + product + " "
    }
    result += "10^(" + str(upper.exponent) + ")"
  }

  // Wrap in brackets if necessary.
  let exponent = lower.exponent == upper.exponent and lower.exponent != none
  let parantheses = follows-unit or exponent
  if parantheses {
    result = "lr((" + result + "))"
  }
  
  // Append common exponent.
  if exponent {
    result += " " + product + " 10^(" + str(lower.exponent) + ")"
  }

  result
}
