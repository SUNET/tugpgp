use serde::{Deserialize, Serialize};
use tauri::State;
use wecanencrypt::{
    create_key, parse_cert_bytes, get_ssh_pubkey,
    CipherSuite, SubkeyFlags, KeyType,
};

use super::AppState;

#[derive(Debug, Serialize, Deserialize)]
pub struct SubkeyInfo {
    #[serde(rename = "keyType")]
    pub key_type: String,
    pub fingerprint: String,
    pub expiry: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct KeyData {
    #[serde(rename = "publicKey")]
    pub public_key: String,
    #[serde(rename = "secretKey")]
    pub secret_key: String,
    pub fingerprint: String,
    #[serde(rename = "sshPublicKey")]
    pub ssh_public_key: String,
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
pub async fn generate_key(
    state: State<'_, AppState>,
    name: String,
    emails: Vec<String>,
    password: String,
) -> Result<KeyData, String> {
    println!("Generating key for: {} with emails: {:?}", name, emails);

    // Build user IDs in the format "Name <email>"
    let user_ids: Vec<String> = emails
        .iter()
        .map(|email| format!("{} <{}>", name, email))
        .collect();
    let user_id_refs: Vec<&str> = user_ids.iter().map(|s| s.as_str()).collect();

    // Generate key with:
    // - Primary key with signing capability
    // - Encryption subkey
    // - Authentication subkey
    // - No separate signing subkey
    let subkey_flags = SubkeyFlags {
        encryption: true,
        signing: false,
        authentication: true,
    };

    let generated = create_key(
        &password,
        &user_id_refs,
        CipherSuite::Cv25519,
        None,  // creation_time (use default)
        None,  // expiration_time (no expiry for now)
        None,  // subkeys_expiration
        subkey_flags,
        true,  // can_primary_sign
        true,  // can_primary_expire
    ).map_err(|e| format!("Key generation failed: {}", e))?;

    // Parse the generated certificate to get subkey information
    let cert_info = parse_cert_bytes(&generated.secret_key, true)
        .map_err(|e| format!("Failed to parse generated key: {}", e))?;

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

    // Get SSH public key (from authentication subkey)
    let ssh_public_key = get_ssh_pubkey(&generated.secret_key, None)
        .unwrap_or_else(|_| "SSH key not available".to_string());

    // Store the secret key and password in state for later upload to Yubikey
    {
        let mut sk = state.secret_key.lock().unwrap();
        *sk = Some(generated.secret_key.clone());
    }
    {
        let mut pw = state.key_password.lock().unwrap();
        *pw = Some(password);
    }

    println!("Key generated successfully. Fingerprint: {}", generated.fingerprint);

    Ok(KeyData {
        public_key: generated.public_key,
        secret_key: String::new(), // Don't send secret key to frontend
        fingerprint: format_fingerprint(&generated.fingerprint),
        ssh_public_key,
        subkeys,
    })
}
