use serde::{Deserialize, Serialize};
use std::fs;
use std::path::Path;
use wecanencrypt::{parse_cert_file, KeyType};

use super::keygen::SubkeyInfo;

#[derive(Debug, Serialize, Deserialize)]
pub struct ParsedKeyData {
    pub fingerprint: String,
    pub expiry: String,
    #[serde(rename = "userId")]
    pub user_id: String,
    pub subkeys: Vec<SubkeyInfo>,
}

/// Format a fingerprint with spaces for display (groups of 4)
fn format_fingerprint(fp: &str) -> String {
    fp.chars()
        .collect::<Vec<_>>()
        .chunks(4)
        .map(|c| c.iter().collect::<String>())
        .collect::<Vec<_>>()
        .join(" ")
        .to_uppercase()
}

/// Convert wecanencrypt KeyType to display string
fn key_type_to_string(kt: &KeyType) -> String {
    match kt {
        KeyType::Encryption => "Encryption".to_string(),
        KeyType::Signing => "Signing".to_string(),
        KeyType::Authentication => "Authentication".to_string(),
        KeyType::Certification => "Certification".to_string(),
        KeyType::Unknown => "Unknown".to_string(),
    }
}

#[tauri::command]
pub fn parse_public_key(file_path: String) -> Result<ParsedKeyData, String> {
    println!("Parsing public key: {}", file_path);

    // Check if file exists
    if !Path::new(&file_path).exists() {
        return Err(format!("File not found: {}", file_path));
    }

    // Parse the certificate file
    let cert_info = parse_cert_file(&file_path, true)
        .map_err(|e| format!("Failed to parse key file: {}", e))?;

    // Get the first user ID or a default
    let user_id = cert_info.user_ids
        .first()
        .cloned()
        .unwrap_or_else(|| "Unknown".to_string());

    // Format expiry date
    let expiry = cert_info.expiration_time
        .map(|dt| dt.format("%Y-%m-%d").to_string())
        .unwrap_or_else(|| "Never".to_string());

    // Build subkey info list
    let subkeys: Vec<SubkeyInfo> = cert_info.subkeys
        .iter()
        .map(|sk| SubkeyInfo {
            key_type: key_type_to_string(&sk.key_type),
            fingerprint: format_fingerprint(&sk.fingerprint),
            expiry: sk.expiration_time
                .map(|dt| dt.format("%Y-%m-%d").to_string())
                .unwrap_or_else(|| "Never".to_string()),
        })
        .collect();

    println!("Parsed key with fingerprint: {}", cert_info.fingerprint);

    Ok(ParsedKeyData {
        fingerprint: format_fingerprint(&cert_info.fingerprint),
        expiry,
        user_id,
        subkeys,
    })
}

#[tauri::command]
pub fn save_key_to_file(
    dir_path: String,
    filename: String,
    content: String,
) -> Result<String, String> {
    let full_path = Path::new(&dir_path).join(&filename);
    let full_path_str = full_path.to_string_lossy().to_string();

    println!("Saving key to: {}", full_path_str);

    fs::write(&full_path, &content).map_err(|e| format!("Failed to save file: {}", e))?;

    println!("Key saved successfully");
    Ok(full_path_str)
}
