# typst-plugins

This repository contains my packages for [typst](https://github.com/typst/typst). More information about each of the packages can be found in their respective directories.

| Name | Version | Description |
| :--- | :-----: | :---------- |
| [based](based/) | 0.1.0 | Encoder and decoder for base64, base32, and base16. |
| [hash](hash/) | 0.1.0 | A package that implements a multitude of hashing algorithms. |
| [qr](qr/) | 0.1.0 | A package for generating QR codes. |

## Building
Packages that run on top of WASM need to be built before they can be used. The package source directories already contain a symbolic link to the WASM files in the `target/wasm32-unknown-unknown/release` directory, however, they don't exist yet:

- To build all WASM files, run `cargo build -r`
- To only build a specific package, run `cargo build -r -p <package name>`

The commands are to be run in the root directory of this repository.

## License
This repository is licensed under the [MIT License](LICENSE).
