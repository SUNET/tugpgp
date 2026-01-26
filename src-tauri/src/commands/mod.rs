pub mod keygen;
pub mod yubikey;
pub mod files;

pub use keygen::*;
pub use yubikey::*;
pub use files::*;

use std::sync::Mutex;

/// Application state shared across Tauri commands
pub struct AppState {
    /// Generated secret key bytes (stored after key generation for upload)
    pub secret_key: Mutex<Option<Vec<u8>>>,
    /// Password for the secret key
    pub key_password: Mutex<Option<String>>,
}

impl AppState {
    pub fn new() -> Self {
        Self {
            secret_key: Mutex::new(None),
            key_password: Mutex::new(None),
        }
    }
}
