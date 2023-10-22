#import "data.typ": *

// Formats a float with thousands separator.
//
// Parameters:
// - f: Float to format.
// - decsep: Which decimal separator to use. This must be the same as the one used in `f`.
//           Set it to `auto` to automatically choose it. Falls back to `.`.
// - thousandsep: The seperator between the thousands.
#let format-float(
  f,
  decsep: auto,
  thousandsep: "thin"
) = {
  let string = ""
  if decsep == auto {
    decsep = if "," in f { "," } else{ "." }
  }

  if thousandsep.trim() == "." {
    thousandsep = ".#h(0mm)"
  }

  let split = str(f).split(decsep)
  let int-part = split.at(0)
  let dec-part = split.at(1, default: none)
  let int-list = int-part.clusters()

  string += str(int-list.remove(0))
  for (i, n) in int-list.enumerate() {
    let mod = (i - int-list.len()) / 3
    if int(mod) == mod {
      string += " " + thousandsep + " "
    }
    string += str(n)
  }

  if dec-part != none {
    let dec-list = dec-part.clusters()
    string += decsep
    for (i, n) in dec-list.enumerate() {
      let mod = i / 3
      if int(mod) == mod and i != 0 {
        string += " " + thousandsep + " "
      }
      string += str(n)
    }
  }

  string.replace(",", ",#h(0pt)")
}

// Format a number.
//
// Paramaters:
// - value: Value of the number.
// - exponent: Exponent in the exponential notation.
// - upper: Upper uncertainty.
// - lower: Lower uncertainty.
// - thousandsep: The seperator between the thousands of the float.
#let format-number(
  value,
  exponent: none,
  upper: none,
  lower: none,
  thousandsep: "thin"
) = {
  let formatted-value = ""
  if value != none {
    formatted-value += format-float(value, thousandsep: thousandsep)
  }
  if upper != none and lower != none {
    if upper != lower {
      formatted-value += "^(+" + format-float(upper, thousandsep: thousandsep) + ")"
      formatted-value += "_(-" + format-float(lower, thousandsep: thousandsep) + ")"
    } else {
      formatted-value += " plus.minus " + format-float(upper, thousandsep: thousandsep)
    }
  } else if upper != none {
    formatted-value += " plus.minus " + format-float(upper, thousandsep: thousandsep)
  } else if lower != none {
    formatted-value += " plus.minus " + format-float(lower, thousandsep: thousandsep)
  }
  if not (upper == none and lower == none) {
    formatted-value = "lr((" + formatted-value
    formatted-value += "))"
  }
  if exponent != none {
    if value != none {
      formatted-value += " dot "
    }
    formatted-value += "10^(" + str(exponent) + ")"
  }
  formatted-value
}

// TODO: Find out what this does
#let chunk(string, cond) = (string: string, cond: cond)

// Format a unit using the shorthand notation.
//
// Parameters:
// - string: String containing the unit.
// - space: Space between units.
// - per: Whether to format the units after `/` with a fraction or exponent.
#let format-unit-short(
  string,
  space: "thin",
  per: "symbol"
) = {
  assert(per == "symbol" or per == "fraction" or per == "/")

  let formatted = ""

  let split = string
    .replace(regex(" */ *"), "/")
    .replace(regex(" +"), " ")
    .split(regex(" "))
  let chunks = ()
  for s in split {
    let per-split = s.split("/")
    chunks.push(chunk(per-split.at(0), false))
    if per-split.len() > 1 {
      for p in per-split.slice(1) {
        chunks.push(chunk(p, true))
      }
    }
  }

  // needed for fraction formatting
  let normal-list = ()
  let per-list = ()

  let prefixes = ()
  for (string: string, cond: per-set) in chunks {
    let u-space = true
    let prefix = none
    let unit = ""
    let exponent = none

    let qty-exp = string.split("^")
    let quantity = qty-exp.at(0)
    exponent = qty-exp.at(1, default: none)

    if quantity in units-short {
      // Match units without prefixes
      unit = units-short.at(quantity)
      u-space = units-short-space.at(quantity)
    } else {
      // Match prefix + unit
      let pre = ""
      for char in quantity.clusters() {
        pre += char
        // Divide `quantity` into `pre`+`u` and check validity
        if pre in prefixes-short {
          let u = quantity.trim(pre, at: start, repeat: false)
          if u in units-short {
            prefix = prefixes-short.at(pre)
            unit = units-short.at(u)
            u-space = units-short-space.at(u)

            pre = none
            break
          }
        }
      }
      if pre != none {
        panic("invalid unit: " + quantity)
      }
    }

    if per == "symbol" {
      if u-space {
        formatted += space
      }
      formatted += prefix + unit
      if exponent != none {
        if per-set {
          formatted += "^(-" + exponent + ")"
        } else {
          formatted += "^(" + exponent + ")"
        }
      } else if per-set {
        formatted += "^(-1)"
      }
    } else {
      let final-unit = ""
      // if u-space {
      //   final-unit += space
      // }
      final-unit += prefix + unit
      if exponent != none {
          final-unit += "^(" + exponent + ")"
      }

      if per-set {
        per-list.push(chunk(final-unit, u-space))
      } else {
        normal-list.push(chunk(final-unit, u-space))
      }
    }
  }

  // return((normal-list, per-list))

  if per != "symbol" {
    if normal-list.at(0).at("cond") {
      formatted += space
    }

    if per-list.len() > 0 {
      formatted += " ("
    }
    
    for (i, chunk) in normal-list.enumerate() {
      let (string: n, cond: space-set) = chunk
      if i != 0 and space-set {
        formatted += space
      }
      formatted += n
    }

    if per-list.len() == 0 {
      return formatted
    }

    formatted += ")/("
    for (i, chunk) in per-list.enumerate() {
      let (string: p, cond: space-set) = chunk
      if i != 0 and space-set {
        formatted += space
      }
      formatted += p
    }
    formatted += ")"
  }

  formatted
}

// Format a unit using written-out words.
//
// Parameters:
// - string: String containing the unit.
// - space: Space between units.
// - per: Whether to format the units after `per` with a fraction or exponent.
#let format-unit(
  string,
  space: "thin",
  per: "symbol"
) = {
  assert(per == "symbol" or per == "fraction" or per == "/")

  let formatted = ""

  // needed for fraction formatting
  let normal-list = ()
  let per-list = ()

  // whether per was used
  let per-set = false
  // whether waiting for a postfix
  let post = false
  // one unit
  let unit = chunk("", true)

  let split = lower(string).split(" ")
  split.push("")

  for u in split {
    // expecting postfix
    if post {
      if per == "symbol" {
        // add postfix
        if u in postfixes {
          if per-set {
            unit.at("string") += "^(-"
          } else {
            unit.at("string") += "^("
          }
          unit.at("string") += postfixes.at(u)
          unit.at("string") += ")"

          if unit.at("cond") {
            unit.at("string") = space + unit.at("string")
          }

          per-set = false
          post = false

          formatted += unit.at("string")
          unit = chunk("", true)
          continue
        // add per
        } else if per-set {
          unit.at("string") += "^(-1)"

          if unit.at("cond") {
            unit.at("string") = space + unit.at("string")
          }

          per-set = false
          post = false

          formatted += unit.at("string")
          unit = chunk("", true)
        // finish unit
        } else {
          post = false

          if unit.at("cond") {
            unit.at("string") = space + unit.at("string")
          }

          formatted += unit.at("string")
          unit = chunk("", true)
        }
      } else {
        if u in postfixes {
          unit.at("string") += "^("
          unit.at("string") += postfixes.at(u)
          unit.at("string") += ")"

          if per-set {
            per-list.push(unit)
          } else {
            normal-list.push(unit)
          }

          per-set = false
          post = false

          unit = chunk("", true)
          continue
        } else {
          if per-set {
            per-list.push(unit)
          } else {
            normal-list.push(unit)
          }

          per-set = false
          post = false

          unit = chunk("", true)
        }
      }
    }

    // detected per
    if u == "per" {
      per-set = true
    // add prefix
    } else if u in prefixes {
      unit.at("string") += prefixes.at(u)
    // add unit
    } else if u in units {
      unit.at("string") += units.at(u)
      unit.at("cond") = units-space.at(u)
      post = true
    } else if u != "" {
      return format-unit-short(string, space: space, per: per)
    }
  }

  if per != "symbol" {
    if normal-list.at(0).at("cond") {
      formatted += space
    }

    if per-list.len() > 0 {
      formatted += " ("
    }

    for (i, chunk) in normal-list.enumerate() {
      let (string: n, cond: space-set) = chunk
      if i != 0 and space-set {
        formatted += space
      }
      formatted += n
    }

    if per-list.len() == 0 {
      return formatted
    }

    formatted += ")/("
    for (i, chunk) in per-list.enumerate() {
      let (string: p, cond: space-set) = chunk
      if i != 0 and space-set {
        formatted += space
      }
      formatted += p
    }
    formatted += ")"
  }

  formatted
}

// Format a range.
//
// Parameters:
// - (lower, upper): Strings containing the numbers.
// - (exponent-lower, exponent-upper): Strings containing the exponentials in exponential notation.
// - `delimiter`: Symbol between the numbers.
// - `space`: Space between the numbers and the delimiter.
// - `thousandsep`: The seperator between the thousands of the float.
// - `force-parentheses`: Whether to force parentheses around the range.
#let format-range(
  lower,
  upper, 
  exponent-lower: none,
  exponent-upper: none,
  delimiter: "-",
  space: "thin",
  thousandsep: "thin",
  force-parentheses: false
) = {
  let formatted-value = ""

  formatted-value += format-float(lower, thousandsep: thousandsep)
  if exponent-lower != exponent-upper and exponent-lower != none {
    if lower != none {
      formatted-value += "dot "
    }
    formatted-value += "10^(" + str(exponent-lower) + ")"
  }
  formatted-value += space + " " + delimiter + " " + space + format-float(upper, thousandsep: thousandsep)
  if exponent-lower != exponent-upper and exponent-upper != none {
    if upper != none {
      formatted-value += "dot "
    }
    formatted-value += "10^(" + str(exponent-upper) + ")"
  }
  if exponent-lower == exponent-upper and (exponent-lower != none and exponent-upper != none) {
    formatted-value = "lr((" + formatted-value
    formatted-value += ")) dot 10^(" + str(exponent-lower) + ")"
  } else if force-parentheses {
    formatted-value = "lr((" + formatted-value
    formatted-value += "))"
  }
  formatted-value
}
