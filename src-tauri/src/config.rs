use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

/// Represents the intensity level of obfuscation transformations.
/// Higher intensity provides stronger protection but may increase binary size
/// and compilation time.
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq)]
pub enum ObfuscationIntensity {
    /// Minimal obfuscation with negligible performance impact
    Low,
    /// Balanced obfuscation suitable for most use cases
    Medium,
    /// Aggressive obfuscation for maximum protection
    High,
    /// Custom intensity with fine-grained control
    Custom,
}

impl Default for ObfuscationIntensity {
    fn default() -> Self {
        Self::Medium
    }
}

/// Configuration for specific obfuscation techniques.
/// Each technique can be individually enabled or disabled.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TechniqueConfig {
    /// Enable control flow flattening to obscure program logic
    pub control_flow_flattening: bool,
    
    /// Enable string encryption for all string literals
    pub string_encryption: bool,
    
    /// Inject bogus control flow and dead code paths
    pub bogus_code_injection: bool,
    
    /// Replace simple instructions with complex equivalents
    pub instruction_substitution: bool,
    
    /// Apply function inlining and outlining transformations
    pub function_manipulation: bool,
    
    /// Add opaque predicates to confuse static analysis
    pub opaque_predicates: bool,
}

impl Default for TechniqueConfig {
    fn default() -> Self {
        Self {
            control_flow_flattening: true,
            string_encryption: true,
            bogus_code_injection: true,
            instruction_substitution: true,
            function_manipulation: false,
            opaque_predicates: true,
        }
    }
}

impl TechniqueConfig {
    /// Returns a configuration with all techniques enabled
    pub fn all_enabled() -> Self {
        Self {
            control_flow_flattening: true,
            string_encryption: true,
            bogus_code_injection: true,
            instruction_substitution: true,
            function_manipulation: true,
            opaque_predicates: true,
        }
    }

    /// Returns a configuration with minimal obfuscation
    pub fn minimal() -> Self {
        Self {
            control_flow_flattening: false,
            string_encryption: true,
            bogus_code_injection: false,
            instruction_substitution: false,
            function_manipulation: false,
            opaque_predicates: false,
        }
    }
}

/// Main configuration structure for the obfuscation process
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ObfuscationConfig {
    /// Overall intensity level
    pub intensity: ObfuscationIntensity,
    
    /// Individual technique toggles
    pub techniques: TechniqueConfig,
    
    /// Preserve debug symbols in output binary
    pub preserve_debug_info: bool,
    
    /// Generate detailed obfuscation report
    pub generate_report: bool,
    
    /// Random seed for reproducible obfuscation (None = random)
    pub seed: Option<u64>,
    
    /// Maximum increase in binary size (percentage)
    pub max_size_increase: Option<u32>,
}

impl Default for ObfuscationConfig {
    fn default() -> Self {
        Self {
            intensity: ObfuscationIntensity::default(),
            techniques: TechniqueConfig::default(),
            preserve_debug_info: false,
            generate_report: true,
            seed: None,
            max_size_increase: Some(150), // Allow up to 150% of original size
        }
    }
}

impl ObfuscationConfig {
    /// Creates a new configuration with default settings
    pub fn new() -> Self {
        Self::default()
    }

    /// Adjusts technique settings based on intensity level
    pub fn apply_intensity(&mut self) {
        match self.intensity {
            ObfuscationIntensity::Low => {
                self.techniques = TechniqueConfig::minimal();
            }
            ObfuscationIntensity::Medium => {
                self.techniques = TechniqueConfig::default();
            }
            ObfuscationIntensity::High => {
                self.techniques = TechniqueConfig::all_enabled();
            }
            ObfuscationIntensity::Custom => {
                // Keep existing technique configuration
            }
        }
    }

    /// Loads configuration from a JSON file
    pub fn from_file(path: &PathBuf) -> Result<Self, ConfigError> {
        let content = fs::read_to_string(path)
            .map_err(|e| ConfigError::IoError(format!("Failed to read config file: {}", e)))?;
        
        let config: ObfuscationConfig = serde_json::from_str(&content)
            .map_err(|e| ConfigError::ParseError(format!("Invalid config format: {}", e)))?;
        
        Ok(config)
    }

    /// Saves configuration to a JSON file
    pub fn save_to_file(&self, path: &PathBuf) -> Result<(), ConfigError> {
        let json = serde_json::to_string_pretty(self)
            .map_err(|e| ConfigError::SerializeError(format!("Failed to serialize config: {}", e)))?;
        
        fs::write(path, json)
            .map_err(|e| ConfigError::IoError(format!("Failed to write config file: {}", e)))?;
        
        Ok(())
    }

    /// Validates the configuration for correctness
    pub fn validate(&self) -> Result<(), ConfigError> {
        if let Some(max_increase) = self.max_size_increase {
            if max_increase < 100 {
                return Err(ConfigError::ValidationError(
                    "Maximum size increase must be at least 100%".to_string()
                ));
            }
        }

        // Ensure at least one technique is enabled
        if self.intensity != ObfuscationIntensity::Custom {
            return Ok(());
        }

        let any_enabled = self.techniques.control_flow_flattening
            || self.techniques.string_encryption
            || self.techniques.bogus_code_injection
            || self.techniques.instruction_substitution
            || self.techniques.function_manipulation
            || self.techniques.opaque_predicates;

        if !any_enabled {
            return Err(ConfigError::ValidationError(
                "At least one obfuscation technique must be enabled".to_string()
            ));
        }

        Ok(())
    }
}

/// Errors that can occur during configuration handling
#[derive(Debug)]
pub enum ConfigError {
    IoError(String),
    ParseError(String),
    SerializeError(String),
    ValidationError(String),
}

impl std::fmt::Display for ConfigError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ConfigError::IoError(msg) => write!(f, "I/O error: {}", msg),
            ConfigError::ParseError(msg) => write!(f, "Parse error: {}", msg),
            ConfigError::SerializeError(msg) => write!(f, "Serialization error: {}", msg),
            ConfigError::ValidationError(msg) => write!(f, "Validation error: {}", msg),
        }
    }
}

impl std::error::Error for ConfigError {}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_default_config() {
        let config = ObfuscationConfig::default();
        assert_eq!(config.intensity, ObfuscationIntensity::Medium);
        assert!(config.generate_report);
    }

    #[test]
    fn test_intensity_application() {
        let mut config = ObfuscationConfig::new();
        
        config.intensity = ObfuscationIntensity::Low;
        config.apply_intensity();
        assert!(!config.techniques.control_flow_flattening);
        
        config.intensity = ObfuscationIntensity::High;
        config.apply_intensity();
        assert!(config.techniques.function_manipulation);
    }

    #[test]
    fn test_validation() {
        let mut config = ObfuscationConfig::new();
        assert!(config.validate().is_ok());

        config.max_size_increase = Some(50);
        assert!(config.validate().is_err());
    }
}
