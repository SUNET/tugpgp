mod commands;

use commands::{
    generate_key, is_yubikey_connected, upload_to_yubikey,
    set_user_pin, set_admin_pin, update_key_expiry,
    parse_public_key, save_key_to_file,
    AppState,
};

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_fs::init())
        .manage(AppState::new())
        .invoke_handler(tauri::generate_handler![
            generate_key,
            is_yubikey_connected,
            upload_to_yubikey,
            set_user_pin,
            set_admin_pin,
            update_key_expiry,
            parse_public_key,
            save_key_to_file,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
