use base64::{Engine, engine::general_purpose::STANDARD_NO_PAD};
use wasm_minimal_protocol::*;

initiate_protocol!();

#[wasm_func]
pub fn encode(data: &[u8]) -> Vec<u8> {
    STANDARD_NO_PAD.encode(data).into_bytes()
}

#[wasm_func]
pub fn decode(data: &[u8]) -> Result<Vec<u8>, String> {
    STANDARD_NO_PAD.decode(data).map_err(|e| e.to_string())
}
