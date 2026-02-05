package nf.plugin.extensions

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j

/**
 * Validation utilities following nf-core best practices
 * 
 * Provides methods for:
 * - Parameter validation
 * - Schema validation
 * - File path checking
 * - Type validation
 */
@Slf4j
@CompileStatic
class ValidationExtension {
    
    /**
     * Validate that a parameter is not null or empty
     * 
     * @param value The value to validate
     * @param paramName The name of the parameter (for error messages)
     * @return true if valid
     * @throws IllegalArgumentException if invalid
     */
    static boolean validateRequired(Object value, String paramName) {
        if (value == null) {
            throw new IllegalArgumentException("Required parameter '${paramName}' is missing")
        }
        if (value instanceof String && ((String) value).trim().isEmpty()) {
            throw new IllegalArgumentException("Required parameter '${paramName}' cannot be empty")
        }
        log.debug("Parameter '${paramName}' validated successfully")
        return true
    }
    
    /**
     * Validate that a file path exists
     * 
     * @param path The file path to validate
     * @param paramName The name of the parameter (for error messages)
     * @return true if valid
     * @throws IllegalArgumentException if file doesn't exist
     */
    static boolean validateFilePath(String path, String paramName) {
        validateRequired(path, paramName)
        File file = new File(path)
        if (!file.exists()) {
            throw new IllegalArgumentException("File specified in '${paramName}' does not exist: ${path}")
        }
        log.debug("File path '${path}' validated successfully")
        return true
    }
    
    /**
     * Validate that a parameter is within a specified range
     * 
     * @param value The numeric value to validate
     * @param min Minimum allowed value (inclusive)
     * @param max Maximum allowed value (inclusive)
     * @param paramName The name of the parameter
     * @return true if valid
     * @throws IllegalArgumentException if out of range
     */
    static boolean validateRange(Number value, Number min, Number max, String paramName) {
        validateRequired(value, paramName)
        if (value < min || value > max) {
            throw new IllegalArgumentException("Parameter '${paramName}' must be between ${min} and ${max}, got: ${value}")
        }
        log.debug("Parameter '${paramName}' is within valid range")
        return true
    }
    
    /**
     * Validate that a parameter is one of the allowed values
     * 
     * @param value The value to validate
     * @param allowedValues List of allowed values
     * @param paramName The name of the parameter
     * @return true if valid
     * @throws IllegalArgumentException if not in allowed values
     */
    static boolean validateEnum(Object value, List allowedValues, String paramName) {
        validateRequired(value, paramName)
        if (!allowedValues.contains(value)) {
            throw new IllegalArgumentException("Parameter '${paramName}' must be one of ${allowedValues}, got: ${value}")
        }
        log.debug("Parameter '${paramName}' is a valid enum value")
        return true
    }
    
    /**
     * Validate an email address format
     * 
     * @param email The email to validate
     * @param paramName The name of the parameter
     * @return true if valid
     * @throws IllegalArgumentException if invalid format
     */
    static boolean validateEmail(String email, String paramName) {
        validateRequired(email, paramName)
        def emailPattern = ~/^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        if (!email.matches(emailPattern)) {
            throw new IllegalArgumentException("Parameter '${paramName}' is not a valid email address: ${email}")
        }
        log.debug("Email '${email}' validated successfully")
        return true
    }
}
