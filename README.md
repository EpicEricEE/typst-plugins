# typst-plugins

This repository contains my packages for [typst](https://github.com/typst/typst). More information about each of the packages can be found in their respective directories.

| Name | Version | Description |
| :--- | :-----: | :---------- |
| [based](based/) | 0.1.0 | Encoder and decoder for base64, base32, and base16. |
| [hash](hash/) | 0.1.0 | Implementation of multiple hashing algorithms. |
| [outex](outex/) | 0.1.0 | Outlines styled like in LaTeX. |
| [qr](qr/) | 0.1.0 | Fast QR Code generator. |
| [quick-maths](quick-maths/) | 0.1.0 | Custom shorthands for math equations. |

## Building
Packages that run on top of WASM need to be built before they can be used. The package source directories already contain the compiled WASM files of the latest state. To build the WASM files yourself, you need to have [Rust](https://www.rust-lang.org/) installed with the `wasm32-unknown-unknown` target.

- To build all WASM files, run `cargo build -r`
- To only build a specific package, run `cargo build -r -p <package name>`
- After building, the WASM files can be found in `target/wasm32-unknown-unknown/release/`

The commands are to be run in the root directory of this repository.

## License
This repository is licensed under the [MIT License](LICENSE).
