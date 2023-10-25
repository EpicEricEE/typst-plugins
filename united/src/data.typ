#let eval = eval.with(mode: "math")

// Load a CSV file with prefixes.
//
// Parameters:
// - path: Path of the CSV file.
// - delimiter: Passed to the `csv` function.
#let read-prefixes(path, delimiter: ",") = {
  let array = csv(path, delimiter: delimiter)
  let prefixes = (:)
  let prefixes-short = (:)

  for (name, short, value) in array {
    prefixes.insert(lower(name), eval(value))
    prefixes-short.insert(short, eval(value))
  }

  (prefixes, prefixes-short)
}

// Load a CSV file with postfixes.
//
// Parameters:
// - path: Path of the CSV file.
// - delimiter: Passed to the `csv` function.
#let read-postfixes(path, delimiter: ",") = {
  let array = csv(path, delimiter: delimiter)
  let postfixes = (:)

  for (name, value) in array {
    postfixes.insert(lower(name), eval(value))
  }

  postfixes
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

  for (name, short, value, space) in array {
    units.insert(lower(name), eval(value))
    units-short.insert(short, eval(value))

    space = space in ("true", "1")
    units-space.insert(lower(name), space)
    units-short-space.insert(short, space)
  }

  (units, units-short, units-space, units-short-space)
}

// Load data from assets.

#let (
  prefixes,
  prefixes-short
) = read-prefixes("../assets/prefixes.csv")

#let (
  units,
  units-short,
  units-space,
  units-short-space
) = read-units("../assets/units.csv")

#let postfixes = read-postfixes("../assets/postfixes.csv")
