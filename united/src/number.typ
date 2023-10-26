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
  if type(value) == dictionary {
    // ! Necessary for `format-range` to work.
    return value
  }

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
// - group-sep: The separator between digit groups.
#let format-float(
  value,
  decimal-sep: ".",
  group-sep: math.thin,
) = {
  value = str(value)

  let split = value.split(".")
  let int-part = split.at(0)
  let dec-part = split.at(1, default: none)

  let result = []
  
  // Append integer part.
  let digits = int-part.clusters()
  result += if digits.len() < 5 or group-sep == none {
    digits.join()
  } else {
    digits.remove(0)
    for (i, digit) in digits.enumerate() {
      if calc.rem(digits.len() - i, 3) == 0 {
        [#group-sep]
      }
      digit
    }
  }

  // Append decimal part.
  if dec-part != none {
    result += decimal-sep
    let digits = dec-part.clusters()
    result += if digits.len() < 5 or group-sep == none {
      digits.join()
    } else {
      for (i, digit) in digits.enumerate() {
        if i not in (0, digits.len() - 1) and calc.rem(i, 3) == 0 {
          [#group-sep]
        }
        digit
      }
    }
  }

  show ",": math.class.with("normal") // Remove space after comma.
  show "-": math.minus // Show proper minus sign instead of hyphen.
  result
}

// Format a number.
//
// Parameters:
// - string: The string containing the number.
// - product: The symbol to use for the exponent product.
// - uncertainty: How to display uncertainties.
// - decimal-sep: The decimal separator.
// - group-sep: The separator between digit groups.
// - follows-unit: Whether this number is followed by a unit.
#let format-number(
  string,
  product: math.dot,
  uncertainty: "plusminus",
  decimal-sep: ".",
  group-sep: math.thin,
  follows-unit: false
) = {
  assert(
    uncertainty in ("plusminus", "parentheses"),
    message: "invalid uncertainty mode: " + uncertainty
  )

  let (value, exponent, lower, upper) = parse-number(string)
  if exponent == "0" { exponent = none }

  let format-float = format-float.with(
    decimal-sep: decimal-sep,
    group-sep: group-sep
  )

  let result = []

  // Append main value.
  let uncertain = upper != none or lower != none
  if value != none {
    // Don't show value if it is 1 and there is an exponent.
    if value != "1" or uncertain or exponent == none {
      result += format-float(value)
    }
  }

  // Append uncertainties.
  if upper != none and lower not in (none, upper) {
    // Always use plus/minus if uncertainties are different.
    result = math.attach(
      result,
      tr: math.plus + format-float(upper),
      br: math.minus + format-float(lower)
    )
  } else if upper != none or lower != none {
    let error = if upper != none { upper } else { lower }

    result += if uncertainty == "plusminus" {
      math.plus.minus + format-float(error)
    } else {
      // Pad with zeros to match lengths of decimals.
      let decimal-len = value.rev().position(".")
      let error-decimal-len = error.rev().position(".")
      if decimal-len == none { decimal-len = 0 }
      if error-decimal-len == none { error-decimal-len = 0 }

      if decimal-len < error-decimal-len {
        if decimal-len == 0 [#decimal-sep]
        "0" * (error-decimal-len - decimal-len)
      } else if error-decimal-len < decimal-len {
        error += "0" * (decimal-len - error-decimal-len)
      }
      
      math.lr[(#error.replace(".", "").trim("0", at: start))]
    }
  }

  // Wrap in brackets if necessary.
  let uncertain = upper != none or lower != none
  let plusminus = uncertainty == "plusminus" or upper != lower
  let exponent-product = value != none and exponent != none
  let parentheses = uncertain and plusminus and (follows-unit or exponent-product)
  if parentheses {
    result = math.lr[(#result)]
  }

  // Append exponent.
  if exponent != none {
    if value != none {
      // Same as above, don't show product if only the exponent is left.
      if value != "1" or uncertain or exponent == none {
        result += product
      }
    }
    result += math.attach([10], tr: format-float(exponent))
  }

  result
}

// Format a range.
//
// Parameters:
// - lower: The string containing the lower bound.
// - upper: The string containing the upper bound.
// - product: The symbol to use for the exponent product.
// - uncertainty: How to display uncertainties.
// - decimal-sep: The decimal separator.
// - group-sep: The separator between digit groups.
// - delim: Symbol between the numbers.
// - delim-space: Space between the numbers and the delimiter.
// - follows-unit: Whether this range is followed by a unit.
#let format-range(
  lower,
  upper,
  product: math.dot,
  uncertainty: "plusminus",
  decimal-sep: ".",
  group-sep: math.thin,
  delim: "to",
  delim-space: math.space,
  follows-unit: false,
) = {
  let lower = parse-number(lower)
  let upper = parse-number(upper)

  let format-float = format-float.with(
    decimal-sep: decimal-sep,
    group-sep: group-sep
  )

  let format-number = format-number.with(
    product: product,
    uncertainty: uncertainty,
    decimal-sep: decimal-sep,
    group-sep: group-sep,
    follows-unit: follows-unit
  )

  let common-exponent = {
    if lower.exponent == upper.exponent and lower.exponent != none {
      format-float(lower.exponent)
      // Remove exponent from numbers.
      lower.exponent = none
      upper.exponent = none
    }
  }

  let result = []

  // Append numbers and delimiter.
  // ! `format-number` takes a string, but these numbers are already parsed.
  // ! This is why `parse-number` includes a short-circuit for dictionaries.
  result += format-number(lower)
  result += [#delim-space] + math.upright(delim) + [#delim-space]
  result += format-number(upper)

  // Wrap in brackets if necessary.
  let parantheses = follows-unit or common-exponent != none
  if parantheses {
    result = math.lr[(#result)]
  }
  
  // Append common exponent.
  if common-exponent != none {
    result += product + math.attach([10], tr: common-exponent)
  }

  result
}
