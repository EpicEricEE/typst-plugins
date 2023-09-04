use digest::Digest;
use wasm_minimal_protocol::*;

initiate_protocol!();

#[wasm_func]
pub fn hash(hasher: &[u8], data: &[u8]) -> Result<Vec<u8>, String> {
    match hasher {
        b"blake2" => Ok(blake2::Blake2b512::digest(data).to_vec()),
        b"blake2s" => Ok(blake2::Blake2s256::digest(data).to_vec()),
        b"md5" => Ok(md5::Md5::digest(data).to_vec()),
        b"sha1" => Ok(sha1::Sha1::digest(data).to_vec()),
        b"sha224" => Ok(sha2::Sha224::digest(data).to_vec()),
        b"sha256" => Ok(sha2::Sha256::digest(data).to_vec()),
        b"sha384" => Ok(sha2::Sha384::digest(data).to_vec()),
        b"sha512" => Ok(sha2::Sha512::digest(data).to_vec()),
        b"sha3" => Ok(sha3::Sha3_512::digest(data).to_vec()),
        _ => Err(r#"expected "blake2", "blake2s", "md5", "sha1", "sha224", "sha256", "sha384", "sha512", or "sha3""#.to_string()),
    }
}
