# typst-plugins

> [!WARNING]
> This repository has been archived. Packages published to the Typst Universe have been moved to their own repositories:
> - [EpicEricEE/typst-based](https://github.com/EpicEricEE/typst-based)
> - [EpicEricEE/typst-droplet](https://github.com/EpicEricEE/typst-droplet)
> - [EpicEricEE/typst-equate](https://github.com/EpicEricEE/typst-equate)
> - [EpicEricEE/typst-quick-maths](https://github.com/EpicEricEE/typst-quick-maths)
>
> The packages are still available in the `@preview` namespace.

This repository contains my packages for [Typst](https://github.com/typst/typst). More information about each of the packages can be found in their respective directories.

| Name                        | Version        | Description                                         |
|-----------------------------|----------------|-----------------------------------------------------|
| [based](based/)             | 0.1.0 [:link:] | Encoder and decoder for base64, base32, and base16. |
| [droplet](droplet/)         | 0.2.0 [:link:] | Customizable dropped capitals.                      |
| [equate](equate/)           | 0.2.0 [:link:] | Breakable equations with improved numbering.        |
| [hash](hash/)               | 0.1.0          | Implementation of multiple hashing algorithms.      |
| [outex](outex/)             | 0.1.0          | Outlines styled like in LaTeX.                      |
| [qr](qr/)                   | 0.1.0          | Fast QR Code generator.                             |
| [quick-maths](quick-maths/) | 0.1.0 [:link:] | Custom shorthands for math equations.               |
| [united](united/)           | 0.1.0          | Easy typesetting of numbers with units.             |

Packages marked with a :link:  are available in the `@preview` namespace.

## Building
Packages that run on top of WASM need to be built before they can be used. The package source directories already contain the compiled WASM files of the latest state. To build the WASM files yourself, you need to have [Rust](https://www.rust-lang.org/) installed with the `wasm32-unknown-unknown` target.

- To build all WASM files, run `cargo build -r`
- To only build a specific package, run `cargo build -r -p <package name>`
- After building, the WASM files can be found in `target/wasm32-unknown-unknown/release/`

The commands are to be run in the root directory of this repository.

## License
The license for each package is found in its respective subdirectory.

[:link:]: https://typst.app/docs/packages
