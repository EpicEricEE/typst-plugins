#import "data.typ"

// Format a list of unit atoms.
//
// Parameters:
// - atoms: List of
//   - prefix: Prefix of the unit, or `none`.
//   - name: Base unit name.
//   - space: Whether a space is needed before the unit.
//   - exponent: Exponent of the unit.
// - unit-space: Space between atoms.
// - per: How to format unit fractions.
#let format-atoms(
  atoms,
  unit-space: "thin",
  per: "symbol"
) = {
  // Format a single atom.
  let format-atom(atom) = {
    if atom.exponent == "0" { return "" }

    let result = atom.prefix + " " + atom.name
    if atom.exponent != "1" {
      result += "^(" + atom.exponent + ")"
    }

    result
  }

  // Join atoms atoms to a sequence with the unit space as separator.
  let join(atoms) = atoms.map(format-atom).join(" " + unit-space + " ")

  if per == "symbol" {
    // Format as sequence of atoms with positive and negative exponents.
    return join(atoms)
  }
  
  // Partition atoms into normal and inverted ones and adjust exponents.
  let (normal, inverted) = atoms.fold(((), ()), (acc, unit) => {
    let index = if unit.exponent.first() == "-" { 1 } else { 0 }
    acc.at(index).push((..unit, exponent: unit.exponent.slice(index)))
    acc
  })

  if inverted == () {
    // No inverted units, so just join the normal ones.
    return join(normal)
  }

  let numerator = if normal == () { "1" } else { join(normal) }
  let denominator = join(inverted)

  if per == "fraction" {
    return "(" + numerator + ") / (" + denominator + ")"
  } else {
    return numerator + " \/ " + denominator
  }
}

// Parses a unit in the given string using the shorthand notation.
//
// Parameters:
// - base: String containing the base unit. May include a prefix, but not an exponent.
// 
// Returns:
// - prefix: Prefix of the unit, or `none`.
// - name: Base unit.
// - space: Whether a space is needed before the unit.
// - exponent: Exponent of the unit.
#let expect-short-unit(atom, inverted: false) = {
  let split = atom.split("^")
  let base = split.first()
  let exponent = split.at(1, default: "1")

  let unit = data.units-short.at(base, default: none)
  if unit != none {
    // Base is a unit without a prefix.
    return (
      prefix: none,
      name: unit, 
      space: data.units-short-space.at(base),
      exponent: if inverted { "-" } + exponent
    )
  }
  
  // Find first matching prefix + unit
  let prefix = ""
  for char in base.clusters() {
    prefix += char
    
    if prefix in data.prefixes-short {
      let unit = base.slice(prefix.len())
      if unit in data.units-short {
        return (
          prefix: data.prefixes-short.at(prefix),
          name: data.units-short.at(unit),
          space: data.units-short-space.at(unit),
          exponent: if inverted { "-" } + exponent
        )
      }
    }
  }

  // No matching prefix + unit found.
  panic("invalid unit: " + base)
}

// Parses a unit string using the shorthand notation into a list of units.
//
// Parameters:
// - string: String containing the unit.
//
// Returns: List of
// - prefix: Prefix of the unit, or `none`.
// - name: Base unit name.
// - space: Whether a space is needed before the unit.
// - exponent: Exponent of the unit.
// - inverted: Whether the unit is inverted.
#let parse-short-unit(string) = {
  let factors = string
    .replace(regex("\s*/\s*"), "/")
    .replace(regex("\s+"), " ")
    .split(regex(" "))

  let atoms = factors
    .map(factor => factor.split("/"))
    .map(((first, ..rest)) => (
      expect-short-unit(first),
      ..rest.map(expect-short-unit.with(inverted: true))
    ))
    .flatten()

  atoms
}

// Parses the next unit in a list of words using the long notation.
//
// Parameters:
// - words: List of words.
//
// Returns:
// - prefix: Prefix of the unit, or `none`.
// - name: Base unit name.
// - space: Whether a space is needed before the unit.
// - exponent: Exponent of the unit.
// - index: Index of the next word.
#let expect-long-unit(words) = {
  let word-count = 0
  
  // Check if unit is inverted.
  let next = words.at(word-count, default: none)
  assert.ne(next, none, message: "expected unit")
  let inverted = next == "per"
  if inverted {
    word-count += 1
  }

  // Check if prefix is given.
  let (curr, next) = (next, words.at(word-count, default: none))
  assert.ne(next, none, message: "expected unit after \"" + curr + "\"")
  let prefix = data.prefixes.at(next, default: none)
  if prefix != none {
    word-count += 1
  }

  // Expect main unit.
  let (curr, next) = (next, words.at(word-count, default: none))
  assert.ne(next, none, message: "expected unit after \"" + curr + "\"")
  let unit = data.units.at(next, default: none)
  let space = data.units-space.at(next, default: none)
  assert.ne(unit, none, message: "invalid unit: " + next)
  word-count += 1

  // Check if exponent is given.
  let next = words.at(word-count, default: none)
  let exponent = if next != none {
    data.postfixes.at(next, default: none)
  }
  if exponent != none {
    word-count += 1
  } else {
    exponent = "1"
  }

  return (
    prefix: prefix,
    name: unit,
    space: space,
    exponent: if inverted { "-" } + exponent,
    word-count: word-count
  )
}

// Parses a unit string using the long notation into a list of units.
//
// Parameters:
// - string: String containing the unit.
//
// Returns: List of
// - prefix: Prefix of the unit, or `none`.
// - name: Base unit name.
// - space: Whether a space is needed before the unit.
// - exponent: Exponent of the unit.
// - inverted: Whether the unit is inverted.
#let parse-long-unit(string) = {
  let words = lower(string)
    .replace(regex("\s+"), " ")
    .split(regex(" "))

  let i = 0
  let units = ()
  while i < words.len() {
    let (word-count, ..unit) = expect-long-unit(words.slice(i))
    units.push(unit)
    i += word-count
  }

  units
}

// Format the given unit string.
//
// The unit can be given in shorthand notation (e.g. "m/s^2") or as written-out
// words (e.g. "meter per second squared").
//
// Parameters:
// - string: String containing the unit.
// - unit-space: Space between units.
// - per: How to format unit fractions.
#let format-unit(
  string,
  unit-space: "thin",
  per: "symbol",
  prefix-space: false,
) = {
  let long = {
    // Check whether the first word is characteristic for the long notation.
    let first = lower(string).trim().split(" ").first()
    first == "per" or first in data.prefixes or first in data.units
  }

  let atoms = if long {
    parse-long-unit(string)
  } else {
    parse-short-unit(string)
  }

  // Prefix with unit-space if needed.
  let result = format-atoms(atoms, unit-space: unit-space, per: per)
  if prefix-space and atoms.first().space {
    result = unit-space + " " + result
  }

  result
}
