#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: 0pt)

// Test cases from: https://www.rfc-editor.org/rfc/rfc4648#section-10

#{
  // Test Base64
  assert.eq(encode64(""), "")
  assert.eq(encode64("f"), "Zg==")
  assert.eq(encode64("fo"), "Zm8=")
  assert.eq(encode64("foo"), "Zm9v")
  assert.eq(encode64("foob"), "Zm9vYg==")
  assert.eq(encode64("fooba"), "Zm9vYmE=")
  assert.eq(encode64("foobar"), "Zm9vYmFy")

  // Test Base32
  assert.eq(encode32(""), "")
  assert.eq(encode32("f"), "MY======")
  assert.eq(encode32("fo"), "MZXQ====")
  assert.eq(encode32("foo"), "MZXW6===")
  assert.eq(encode32("foob"), "MZXW6YQ=")
  assert.eq(encode32("fooba"), "MZXW6YTB")
  assert.eq(encode32("foobar"), "MZXW6YTBOI======")

  // Test Base64 with extended hex alphabet
  assert.eq(encode32(hex: true, ""), "")
  assert.eq(encode32(hex: true, "f"), "CO======")
  assert.eq(encode32(hex: true, "fo"), "CPNG====")
  assert.eq(encode32(hex: true, "foo"), "CPNMU===")
  assert.eq(encode32(hex: true, "foob"), "CPNMUOG=")
  assert.eq(encode32(hex: true, "fooba"), "CPNMUOJ1")
  assert.eq(encode32(hex: true, "foobar"), "CPNMUOJ1E8======")

  // Test Base16
  assert.eq(encode16(""), "")
  assert.eq(encode16("f"), "66")
  assert.eq(encode16("fo"), "666f")
  assert.eq(encode16("foo"), "666f6f")
  assert.eq(encode16("foob"), "666f6f62")
  assert.eq(encode16("fooba"), "666f6f6261")
  assert.eq(encode16("foobar"), "666f6f626172")
}
