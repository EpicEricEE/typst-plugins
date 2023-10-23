// Load a CSV file with prefixes.
//
// Parameters:
// - path: Path of the CSV file.
// - delimiter: Passed to the `csv` function.
#let read-prefixes(path, delimiter: ",") = {
  let array = csv(path, delimiter: delimiter)
  let symbols = (:)
  let symbols-short = (:)

  for line in array {
    symbols.insert(lower(line.at(0)), line.at(2))
    symbols-short.insert(line.at(1), line.at(2))
  }

  (symbols, symbols-short)
}

// Load a CSV file with postfixes.
//
// Parameters:
// - path: Path of the CSV file.
// - delimiter: Passed to the `csv` function.
#let read-postfixes(path, delimiter: ",") = {
  let array = csv(path, delimiter: delimiter)
  let dict = (:)

  for line in array {
    dict.insert(lower(line.at(0)), line.at(1))
  }

  dict
}

// Load a CSV file with units.
//
// Parameters:
// - path: Path of the CSV file.
// - delimiter: Passed to the `csv` function.
#let read-units(path, delimiter: ",") = {
  let array = csv(path, delimiter: delimiter)
  let units = (:)
  let units-short = (:)
  let units-space = (:)
  let units-short-space = (:)

  for line in array {
    units.insert(lower(line.at(0)), line.at(2))
    units-short.insert(line.at(1), line.at(2))
    if line.at(3) == "false" or line.at(3) == "0" {
      units-space.insert(lower(line.at(0)), false)
      units-short-space.insert(line.at(1), false)
    } else {
      units-space.insert(lower(line.at(0)), true)
      units-short-space.insert(line.at(1), true)
    }
  }

  (units, units-short, units-space, units-short-space)
}

// Load data from assets.

#let (
  prefixes,
  prefixes-short
) = read-prefixes("/assets/prefixes.csv")

#let (
  units,
  units-short,
  units-space,
  units-short-space
) = read-units("/assets/units.csv")

#let postfixes = read-postfixes("/assets/postfixes.csv")
