use fast_qr::{QRBuilder, convert::{image::{ImageBuilder, ImageError}, svg::SvgBuilder}};
use wasm_minimal_protocol::*;

initiate_protocol!();

#[wasm_func]
pub fn png(data: &[u8]) -> Result<Vec<u8>, String> {
    let code = QRBuilder::new(data).build().map_err(|e| e.to_string())?;

    ImageBuilder::default().to_bytes(&code).map_err(|e| match e {
        ImageError::EncodingError(s) => s,
        ImageError::ImageError(s) => s,
        ImageError::IoError(e) => e.to_string(),
    })
}

#[wasm_func]
pub fn svg(data: &[u8]) -> Result<Vec<u8>, String> {
    let code = QRBuilder::new(data).build().map_err(|e| e.to_string())?;
    Ok(SvgBuilder::default().to_str(&code).into_bytes())
}
