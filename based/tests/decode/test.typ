#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: 0pt)

// Test cases from: https://www.rfc-editor.org/rfc/rfc4648#section-10

#{
  // Test Base64
  assert.eq(str(decode64("")), "")
  assert.eq(str(decode64("Zg")), "f")
  assert.eq(str(decode64("Zm8=")), "fo")
  assert.eq(str(decode64("Zm9v")), "foo")
  assert.eq(str(decode64("Zm9vYg==")), "foob")
  assert.eq(str(decode64("Zm9vYmE")), "fooba")
  assert.eq(str(decode64("Zm9vYmFy")), "foobar")

  // Test Base32
  assert.eq(str(decode32("")), "")
  assert.eq(str(decode32("MY======")), "f")
  assert.eq(str(decode32("MZXQ")), "fo")
  assert.eq(str(decode32("MZXW6===")), "foo")
  assert.eq(str(decode32("MZXW6YQ=")), "foob")
  assert.eq(str(decode32("MZXW6YTB")), "fooba")
  assert.eq(str(decode32("MZXW6YTBOI")), "foobar")

  // Test Base32 with extended hex alphabet
  assert.eq(str(decode32(hex: true, "")), "")
  assert.eq(str(decode32(hex: true, "CO======")), "f")
  assert.eq(str(decode32(hex: true, "CPNG")), "fo")
  assert.eq(str(decode32(hex: true, "CPNMU===")), "foo")
  assert.eq(str(decode32(hex: true, "CPNMUOG")), "foob")
  assert.eq(str(decode32(hex: true, "CPNMUOJ1")), "fooba")
  assert.eq(str(decode32(hex: true, "CPNMUOJ1E8======")), "foobar")

  // Test Base16
  assert.eq(str(decode16("")), "")
  assert.eq(str(decode16("66")), "f")
  assert.eq(str(decode16("666f")), "fo")
  assert.eq(str(decode16("666F6F")), "foo")
  assert.eq(str(decode16("666f6f62")), "foob")
  assert.eq(str(decode16("666F6F6261")), "fooba")
  assert.eq(str(decode16("666F6f626172")), "foobar")
}
