use std::fs;

// Learn more about Tauri commands at https://tauri.app/develop/calling-rust/
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

#[tauri::command]
fn obfuscate_code(code: String) -> Result<String, String> {
    // TODO: Replace with actual LLVM obfuscation
    // For now, a mock transformation
    let obfuscated = mock_obfuscate(&code);
    Ok(obfuscated)
}

#[tauri::command]
fn save_file(path: String, content: String) -> Result<(), String> {
    fs::write(&path, content).map_err(|e| format!("Failed to save file: {}", e))?;
    Ok(())
}

#[tauri::command]
fn load_file(path: String) -> Result<String, String> {
    fs::read_to_string(&path).map_err(|e| format!("Failed to load file: {}", e))
}

#[tauri::command]
fn compile_code(code: String, output_path: String) -> Result<String, String> {
    // TODO: Spawn g++/clang compiler
    // For now, mock compilation
    Ok(format!("Mock compilation successful: {}", output_path))
}

// Mock obfuscation (replace with LLVM later)
fn mock_obfuscate(code: &str) -> String {
    let mut obfuscated = String::from("/* === OBFUSCATED CODE === */\n");

    // Simple transformations as placeholder
    let transformed = code
        .replace("main", "_0x4d61696e")
        .replace("std::cout", "_0x636f7574")
        .replace("return", "_0x72657475726e");

    obfuscated.push_str(&transformed);
    obfuscated.push_str("\n/* === END OBFUSCATED === */");

    obfuscated
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![
            greet,
            obfuscate_code,
            save_file,
            load_file,
            compile_code
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
