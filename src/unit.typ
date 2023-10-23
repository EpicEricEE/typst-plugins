#import "data.typ"

// Format a list of atoms.
//
// Parameters:
// - atoms: List of
//   - prefix: Prefix of the atom, or `none`.
//   - name: Base name.
//   - space: Whether a space is needed before the atom.
//   - exponent: Exponent of the atom.
// - unit-space: Space between atoms.
// - per: How to format fractions.
#let format-atoms(
  atoms,
  unit-space: "thin",
  per: "symbol"
) = {
  // Format a single atom.
  let format-atom(atom) = {
    let result = atom.prefix + " " + atom.name
    if atom.exponent != "1" {
      result += "^(" + atom.exponent + ")"
    }
    result
  }

  // Remove atoms with zero exponent, as they are equivalent to 1.
  atoms = atoms.filter(atom => atom.exponent != "0")

  // Join atoms into a sequence with the unit space as separator.
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

// Parses an atom string using the shorthand notation.
//
// Parameters:
// - atom: String containing the atom.
// - inverted: Whether the atom is inverted.
// 
// Returns:
// - prefix: Prefix of the atom, or `none`.
// - name: Base name.
// - space: Whether a space is needed before the atom.
// - exponent: Exponent of the atom.
#let expect-short-atom(atom, inverted: false) = {
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

  // No matching prefix + unit name found.
  panic("invalid unit: " + base)
}

// Parses a unit string using the shorthand notation into a list of atoms.
//
// Parameters:
// - string: String containing the unit.
//
// Returns: List of
// - prefix: Prefix of the atom, or `none`.
// - name: Base name.
// - space: Whether a space is needed before the atom.
// - exponent: Exponent of the atom.
#let parse-short-unit(string) = {
  let factors = string
    .replace(regex("\s*/\s*"), "/")
    .replace(regex("\s+"), " ")
    .split(regex(" "))

  let atoms = factors
    .map(factor => factor.split("/"))
    .map(((first, ..rest)) => (
      expect-short-atom(first),
      ..rest.map(expect-short-atom.with(inverted: true))
    ))
    .flatten()

  atoms
}

// Parses the next atom in a list of words using the long notation.
//
// Parameters:
// - words: List of words.
//
// Returns:
// - prefix: Prefix of the atom, or `none`.
// - name: Base name.
// - space: Whether a space is needed before the atom.
// - exponent: Exponent of the atom.
// - index: Index of the next word.
#let expect-long-atom(words) = {
  let word-count = 0
  
  // Check if atom is inverted.
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

  // Expect base atom.
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

// Parses a unit string using the long notation into a list of atoms.
//
// Parameters:
// - string: String containing the unit.
//
// Returns: List of
// - prefix: Prefix of the atom, or `none`.
// - name: Base name.
// - space: Whether a space is needed before the atom.
// - exponent: Exponent of the atom.
// - inverted: Whether the atom is inverted.
#let parse-long-unit(string) = {
  let words = lower(string)
    .replace(regex("\s+"), " ")
    .split(regex(" "))

  let i = 0
  let atoms = ()
  while i < words.len() {
    let (word-count, ..atom) = expect-long-atom(words.slice(i))
    atoms.push(atom)
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
