#import "../data.typ": *

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
