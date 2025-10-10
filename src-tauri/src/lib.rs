mod config;

use config::{ObfuscationConfig, ObfuscationIntensity};
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

/// Represents errors that can occur during obfuscation operations
#[derive(Debug, Serialize, Deserialize)]
pub struct ObfuscationError {
    pub kind: ErrorKind,
    pub message: String,
    pub details: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub enum ErrorKind {
    IoError,
    ParseError,
    CompilationError,
    ObfuscationError,
    ConfigurationError,
}

impl ObfuscationError {
    fn new(kind: ErrorKind, message: impl Into<String>) -> Self {
        Self {
            kind,
            message: message.into(),
            details: None,
        }
    }

    fn with_details(mut self, details: impl Into<String>) -> Self {
        self.details = Some(details.into());
        self
    }
}

impl std::fmt::Display for ObfuscationError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.message)?;
        if let Some(details) = &self.details {
            write!(f, ": {}", details)?;
        }
        Ok(())
    }
}

impl From<std::io::Error> for ObfuscationError {
    fn from(err: std::io::Error) -> Self {
        ObfuscationError::new(ErrorKind::IoError, "I/O operation failed")
            .with_details(err.to_string())
    }
}

impl From<ObfuscationError> for String {
    fn from(err: ObfuscationError) -> String {
        err.to_string()
    }
}

// Learn more about Tauri commands at https://tauri.app/develop/calling-rust/
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

#[tauri::command]
fn obfuscate_code(
    code: String,
    config: Option<ObfuscationConfig>,
) -> Result<String, ObfuscationError> {
    let config = config.unwrap_or_default();
    
    // Validate configuration
    config.validate().map_err(|e| {
        ObfuscationError::new(ErrorKind::ConfigurationError, "Invalid configuration")
            .with_details(e.to_string())
    })?;

    // TODO: Replace with actual LLVM obfuscation
    // For now, use enhanced mock transformation
    let obfuscated = mock_obfuscate(&code, &config)?;
    Ok(obfuscated)
}

#[tauri::command]
fn save_file(path: String, content: String) -> Result<(), ObfuscationError> {
    let path = PathBuf::from(path);
    
    // Validate path
    if path.exists() && path.is_dir() {
        return Err(ObfuscationError::new(
            ErrorKind::IoError,
            "Cannot save: path is a directory",
        ));
    }

    // Create parent directories if needed
    if let Some(parent) = path.parent() {
        if !parent.exists() {
            fs::create_dir_all(parent)?;
        }
    }

    fs::write(&path, content)?;
    Ok(())
}

#[tauri::command]
fn load_file(path: String) -> Result<String, ObfuscationError> {
    let path = PathBuf::from(path);
    
    if !path.exists() {
        return Err(ObfuscationError::new(
            ErrorKind::IoError,
            "File not found",
        ).with_details(format!("Path: {}", path.display())));
    }

    if path.is_dir() {
        return Err(ObfuscationError::new(
            ErrorKind::IoError,
            "Cannot load: path is a directory",
        ));
    }

    let content = fs::read_to_string(&path)?;
    Ok(content)
}

#[tauri::command]
fn compile_code(code: String, output_path: String) -> Result<String, ObfuscationError> {
    // TODO: Spawn g++/clang compiler
    // For now, mock compilation with basic validation
    
    if code.trim().is_empty() {
        return Err(ObfuscationError::new(
            ErrorKind::CompilationError,
            "Cannot compile empty code",
        ));
    }

    let output = PathBuf::from(output_path);
    if let Some(parent) = output.parent() {
        if !parent.exists() {
            fs::create_dir_all(parent)?;
        }
    }

    Ok(format!("Mock compilation successful: {}", output.display()))
}

#[tauri::command]
fn load_config(path: String) -> Result<ObfuscationConfig, ObfuscationError> {
    let path = PathBuf::from(path);
    
    ObfuscationConfig::from_file(&path).map_err(|e| {
        ObfuscationError::new(ErrorKind::ConfigurationError, "Failed to load configuration")
            .with_details(e.to_string())
    })
}

#[tauri::command]
fn save_config(
    config: ObfuscationConfig,
    path: String,
) -> Result<(), ObfuscationError> {
    let path = PathBuf::from(path);
    
    config.validate().map_err(|e| {
        ObfuscationError::new(ErrorKind::ConfigurationError, "Invalid configuration")
            .with_details(e.to_string())
    })?;

    config.save_to_file(&path).map_err(|e| {
        ObfuscationError::new(ErrorKind::ConfigurationError, "Failed to save configuration")
            .with_details(e.to_string())
    })
}

#[tauri::command]
fn get_default_config() -> ObfuscationConfig {
    ObfuscationConfig::default()
}

// Enhanced mock obfuscation with configuration support
fn mock_obfuscate(
    code: &str,
    config: &ObfuscationConfig,
) -> Result<String, ObfuscationError> {
    if code.trim().is_empty() {
        return Err(ObfuscationError::new(
            ErrorKind::ObfuscationError,
            "Cannot obfuscate empty code",
        ));
    }

    let mut obfuscated = String::new();
    
    // Add header with configuration info
    obfuscated.push_str(&format!(
        "/* === OBFUSCATED CODE (Intensity: {:?}) === */\n",
        config.intensity
    ));

    let mut transformed = code.to_string();

    // Apply transformations based on configuration
    if config.techniques.string_encryption {
        obfuscated.push_str("/* String encryption: ENABLED */\n");
    }

    if config.techniques.control_flow_flattening {
        obfuscated.push_str("/* Control flow flattening: ENABLED */\n");
    }

    if config.techniques.instruction_substitution {
        obfuscated.push_str("/* Instruction substitution: ENABLED */\n");
        // Mock instruction substitution
        transformed = transformed
            .replace("main", "_0x4d61696e")
            .replace("std::cout", "_0x636f7574")
            .replace("return", "_0x72657475726e")
            .replace("int ", "_0x696e7420");
    }

    if config.techniques.bogus_code_injection {
        obfuscated.push_str("/* Bogus code injection: ENABLED */\n");
        transformed.insert_str(
            0,
            "volatile int _obf_dummy = 0;\n#define _OBF_NOP() do { _obf_dummy++; } while(0)\n\n",
        );
    }

    obfuscated.push('\n');
    obfuscated.push_str(&transformed);
    obfuscated.push_str("\n/* === END OBFUSCATED === */");

    Ok(obfuscated)
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
            compile_code,
            load_config,
            save_config,
            get_default_config,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
