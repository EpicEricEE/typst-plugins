#import "../src/lib.typ": hash, hex, md5, sha256, sha3

#set text(size: 14pt)
#set page(
  width: auto,
  height: auto,
  margin: 1em,
  background: pad(0.5pt, box(
    width: 100%,
    height: 100%,
    radius: 4pt,
    fill: white,
    stroke: white.darken(10%),
  )),
)

#table(
  columns: 2,
  inset: 0.5em,

  table.header[*Digest*][*Hash*],
  
  [BLAKE2],  hex(hash("blake2", "Hello world!")),
  [BLAKE2s], hex(hash("blake2s", "Hello world!")),
  [MD5],     hex(md5("Hello world!")),
  [SHA-1],   hex(hash("sha1", "Hello world!")),
  [SHA-224], hex(hash("sha224", "Hello world!")),
  [SHA-256], hex(sha256("Hello world!")),
  [SHA-384], hex(hash("sha384", "Hello world!")),
  [SHA-512], hex(hash("sha512", "Hello world!")),
  [SHA-3],   hex(sha3("Hello world!")),
)
