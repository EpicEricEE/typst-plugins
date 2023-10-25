#import "data.typ"

// Format a list of atoms.
//
// Parameters:
// - atoms: List of
//   - prefix: Prefix of the atom, or `none`.
//   - name: Base name.
//   - space: Whether a space is needed before the atom.
//   - exponent: Exponent of the atom.
// - unit-sep: The separator between atoms.
// - per: How to format fractions.
#let format-atoms(
  atoms,
  unit-sep: math.thin,
  per: "reciprocal"
) = {
  // Format a single atom.
  let format-atom(atom) = {
    let result = [#atom.prefix#atom.name]
    if atom.exponent != "1" {
      result = math.attach(result, tr: atom.exponent)
    }
    result
  }

  // Remove atoms with zero exponent, as they are equivalent to 1.
  atoms = atoms.filter(atom => atom.exponent != "0")

  // Join atoms into a sequence with the unit space as separator.
  let join(atoms) = atoms.map(format-atom).join[#unit-sep]

  if per == "reciprocal" {
    // Format as sequence of atoms with positive and negative exponents.
    return join(atoms)
  }
  
  // Partition atoms into normal and inverted ones and adjust exponents.
  let (normal, inverted) = atoms.fold(((), ()), (acc, unit) => {
    let index = if unit.exponent.first() == math.minus { 1 } else { 0 }
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
    return math.frac(numerator, denominator)
  } else {
    if inverted.len() > 1 { 
      denominator = math.lr[(#denominator)]
    }
    return [#numerator#per#denominator]
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
  let exponent = split.at(1, default: "1").replace("-", math.minus)

  let unit = data.units-short.at(base, default: none)
  let space = data.units-short-space.at(base, default: true)

  if unit == none {
    // Check if unit is given in quotes.
    let match = base.match(regex("^'(.+)'$"))
    if match != none {
      unit = math.upright(match.captures.first())
    }
  }

  if unit != none {
    // Base is a unit without a prefix.
    return (
      prefix: none,
      name: unit,
      space: space,
      exponent: if inverted { math.minus } + exponent
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
          exponent: if inverted { math.minus } + exponent
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
  let (prev, next) = (next, words.at(word-count, default: none))
  assert.ne(next, none, message: "expected unit after \"" + prev + "\"")
  let prefix = data.prefixes.at(next, default: none)
  if prefix != none {
    word-count += 1
  }

  // Expect base atom.
  let (prev, next) = (next, words.at(word-count, default: none))
  assert.ne(next, none, message: "expected unit after \"" + prev + "\"")
  let unit = data.units.at(next, default: none)
  if unit == none {
    // Check if unit is given in quotes.
    let match = next.match(regex("^'(.+)'$"))
    if match != none {
      unit = math.upright(match.captures.first())
    }
  }
  let space = data.units-space.at(next, default: true)
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
    exponent: if inverted { math.minus } + exponent,
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

  atoms
}

// Format the given unit string.
//
// The unit can be given in shorthand notation (e.g. "m/s^2") or as written-out
// words (e.g. "meter per second squared").
//
// Parameters:
// - string: String containing the unit.
// - unit-sep: The separator between units.
// - per: How to format unit fractions.
#let format-unit(
  string,
  unit-sep: math.thin,
  per: "reciprocal",
  prefix-space: false,
) = {
  // Check whether any word is characteristic for the long notation.
  let long = lower(string).trim().split(" ").any(word => {
    (("per",), data.prefixes, data.units, data.postfixes).any(d => word in d)
  })

  let atoms = if long {
    parse-long-unit(string)
  } else {
    parse-short-unit(string)
  }

  // Prefix with thin space if required.
  let result = format-atoms(atoms, unit-sep: unit-sep, per: per)
  if prefix-space and atoms.first().space {
    result = math.thin + result
  }

  result
}
