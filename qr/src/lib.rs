use fast_qr::convert::image::{ImageBuilder, ImageError};
use fast_qr::convert::svg::SvgBuilder;
use fast_qr::convert::Builder;
use fast_qr::QRBuilder;
use wasm_minimal_protocol::*;

initiate_protocol!();

#[wasm_func]
pub fn png(
    data: &[u8],
    margin: &[u8],
    fill: &[u8],
) -> Result<Vec<u8>, String> {
    let code = QRBuilder::new(data).build().map_err(|e| e.to_string())?;
    let margin = *margin.get(0).unwrap_or(&0);

    ImageBuilder::default()
        .margin(margin.into())
        .background_color([0, 0, 0, 0]) // Transparent background
        .module_color(fill)
        .to_bytes(&code)
        .map_err(|e| match e {
            ImageError::EncodingError(s) => s,
            ImageError::ImageError(s) => s,
            ImageError::IoError(e) => e.to_string(),
        })
}

#[wasm_func]
pub fn svg(
    data: &[u8],
    margin: &[u8],
    fill: &[u8],
) -> Result<Vec<u8>, String> {
    let code = QRBuilder::new(data).build().map_err(|e| e.to_string())?;
    let margin = *margin.get(0).unwrap_or(&0);

    Ok(SvgBuilder::default()
        .margin(margin.into())
        .background_color([0, 0, 0, 0]) // Transparent background
        .module_color(fill)
        .to_str(&code)
        .into_bytes())
}
