use std::fs;
use std::path::Path;
use tauri::State;
use chrono::{NaiveDate, TimeZone, Utc};
use wecanencrypt::{
    parse_cert_bytes, get_pub_key, KeyType,
    card::{
        is_card_connected, upload_primary_key_to_card, upload_key_to_card,
        change_user_pin, change_admin_pin,
        update_primary_expiry_on_card, update_subkeys_expiry_on_card,
        upload_subkey_by_fingerprint, CardKeySlot,
    },
};

use super::AppState;

/// Default Yubikey PINs
const DEFAULT_USER_PIN: &[u8] = b"123456";
const DEFAULT_ADMIN_PIN: &[u8] = b"12345678";

#[tauri::command]
pub fn is_yubikey_connected() -> bool {
    println!("Checking Yubikey connection...");
    let connected = is_card_connected();
    println!("Yubikey connected: {}", connected);
    connected
}

#[tauri::command]
pub async fn upload_to_yubikey(state: State<'_, AppState>) -> Result<(), String> {
    println!("Uploading keys to Yubikey...");

    // Get secret key and password from state
    let secret_key = {
        let sk = state.secret_key.lock().unwrap();
        sk.clone().ok_or("No key generated. Please generate a key first.")?
    };
    let password = {
        let pw = state.key_password.lock().unwrap();
        pw.clone().ok_or("No password in state.")?
    };

    // Parse the certificate to find subkeys
    let cert_info = parse_cert_bytes(&secret_key, true)
        .map_err(|e| format!("Failed to parse certificate: {}", e))?;

    // Upload primary key to Signing slot (it has signing capability)
    println!("Uploading primary key to Signing slot...");
    upload_primary_key_to_card(
        &secret_key,
        password.as_bytes(),
        CardKeySlot::Signing,
        DEFAULT_ADMIN_PIN,
    ).map_err(|e| format!("Failed to upload primary key: {}", e))?;

    // Verify encryption subkey exists
    let _enc_subkey = cert_info.subkeys.iter()
        .find(|sk| matches!(sk.key_type, KeyType::Encryption))
        .ok_or("No encryption subkey found")?;

    // Upload encryption subkey to Decryption slot
    println!("Uploading encryption subkey to Decryption slot...");
    upload_key_to_card(
        &secret_key,
        password.as_bytes(),
        CardKeySlot::Decryption,
        DEFAULT_ADMIN_PIN,
    ).map_err(|e| format!("Failed to upload encryption subkey: {}", e))?;

    // Upload authentication subkey to Authentication slot
    let auth_subkey = cert_info.subkeys.iter()
        .find(|sk| matches!(sk.key_type, KeyType::Authentication))
        .ok_or("No authentication subkey found")?;

    println!("Uploading authentication subkey to Authentication slot...");
    // Find and upload authentication subkey by fingerprint
    upload_subkey_by_fingerprint(
        &secret_key,
        password.as_bytes(),
        &auth_subkey.fingerprint,
        CardKeySlot::Authentication,
        DEFAULT_ADMIN_PIN,
    ).map_err(|e| format!("Failed to upload authentication subkey: {}", e))?;

    println!("Upload complete!");
    Ok(())
}

#[tauri::command]
pub fn set_user_pin(pin: String) -> Result<(), String> {
    println!("Setting user PIN...");

    if pin.len() < 6 {
        return Err("User PIN must be at least 6 characters".to_string());
    }

    // Change from default PIN to new PIN
    change_user_pin(DEFAULT_USER_PIN, pin.as_bytes())
        .map_err(|e| format!("Failed to set user PIN: {}", e))?;

    println!("User PIN set successfully");
    Ok(())
}

#[tauri::command]
pub fn set_admin_pin(pin: String) -> Result<(), String> {
    println!("Setting admin PIN...");

    if pin.len() < 8 {
        return Err("Admin PIN must be at least 8 characters".to_string());
    }

    // Change from default PIN to new PIN
    change_admin_pin(DEFAULT_ADMIN_PIN, pin.as_bytes())
        .map_err(|e| format!("Failed to set admin PIN: {}", e))?;

    println!("Admin PIN set successfully");
    Ok(())
}

#[tauri::command]
pub async fn update_key_expiry(
    key_path: String,
    new_date: String,
    pin: String,
) -> Result<String, String> {
    println!("Updating key expiry for: {}", key_path);
    println!("New date: {}", new_date);

    // Read the public key file
    let cert_data = fs::read(&key_path)
        .map_err(|e| format!("Failed to read key file: {}", e))?;

    // Parse the date string (expected format: YYYY-MM-DD) and convert to Unix timestamp
    let naive_date = NaiveDate::parse_from_str(&new_date, "%Y-%m-%d")
        .map_err(|e| format!("Invalid date format: {}", e))?;
    let datetime = Utc.from_utc_datetime(&naive_date.and_hms_opt(0, 0, 0).unwrap());
    let expiry_time = datetime.timestamp() as u64;

    // Get all subkey fingerprints for updating
    let cert_info = parse_cert_bytes(&cert_data, true)
        .map_err(|e| format!("Failed to parse certificate: {}", e))?;

    let subkey_fps: Vec<String> = cert_info.subkeys
        .iter()
        .map(|sk| sk.fingerprint.clone())
        .collect();
    let subkey_fp_refs: Vec<&str> = subkey_fps.iter().map(|s| s.as_str()).collect();

    // Update primary key expiry on card
    println!("Updating primary key expiry on card...");
    let updated_cert = update_primary_expiry_on_card(
        &cert_data,
        expiry_time,
        pin.as_bytes(),
    ).map_err(|e| format!("Failed to update primary key expiry: {}", e))?;

    // Update subkeys expiry on card
    println!("Updating subkeys expiry on card...");
    let final_cert = update_subkeys_expiry_on_card(
        &updated_cert,
        &subkey_fp_refs,
        expiry_time,
        pin.as_bytes(),
    ).map_err(|e| format!("Failed to update subkeys expiry: {}", e))?;

    // Get the updated public key (armored)
    let updated_pub_key = get_pub_key(&final_cert)
        .map_err(|e| format!("Failed to export public key: {}", e))?;

    // Save to same directory with updated filename
    let path = Path::new(&key_path);
    let parent = path.parent().unwrap_or(Path::new("."));
    let fingerprint_short = &cert_info.fingerprint[cert_info.fingerprint.len().saturating_sub(16)..];
    let updated_filename = format!("updated_{}.pub", fingerprint_short);
    let updated_path = parent.join(&updated_filename);

    fs::write(&updated_path, updated_pub_key)
        .map_err(|e| format!("Failed to save updated key: {}", e))?;

    let updated_path_str = updated_path.to_string_lossy().to_string();
    println!("Key expiry updated, saved to: {}", updated_path_str);
    Ok(updated_path_str)
}
