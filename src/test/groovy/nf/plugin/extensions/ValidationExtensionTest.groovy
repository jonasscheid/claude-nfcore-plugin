package nf.plugin.extensions

import org.junit.Test
import static org.junit.Assert.*

/**
 * Unit tests for ValidationExtension
 */
class ValidationExtensionTest {

    @Test
    void testValidateRequired_WithValidValue() {
        assertTrue(ValidationExtension.validateRequired("value", "param"))
    }

    @Test(expected = IllegalArgumentException.class)
    void testValidateRequired_WithNull() {
        ValidationExtension.validateRequired(null, "param")
    }

    @Test(expected = IllegalArgumentException.class)
    void testValidateRequired_WithEmptyString() {
        ValidationExtension.validateRequired("", "param")
    }

    @Test
    void testValidateRange_WithinRange() {
        assertTrue(ValidationExtension.validateRange(5, 1, 10, "param"))
    }

    @Test(expected = IllegalArgumentException.class)
    void testValidateRange_BelowMin() {
        ValidationExtension.validateRange(0, 1, 10, "param")
    }

    @Test(expected = IllegalArgumentException.class)
    void testValidateRange_AboveMax() {
        ValidationExtension.validateRange(11, 1, 10, "param")
    }

    @Test
    void testValidateEnum_ValidValue() {
        assertTrue(ValidationExtension.validateEnum("option1", ["option1", "option2", "option3"], "param"))
    }

    @Test(expected = IllegalArgumentException.class)
    void testValidateEnum_InvalidValue() {
        ValidationExtension.validateEnum("invalid", ["option1", "option2", "option3"], "param")
    }

    @Test
    void testValidateEmail_ValidEmail() {
        assertTrue(ValidationExtension.validateEmail("user@example.com", "email"))
    }

    @Test(expected = IllegalArgumentException.class)
    void testValidateEmail_InvalidEmail() {
        ValidationExtension.validateEmail("invalid-email", "email")
    }
}
