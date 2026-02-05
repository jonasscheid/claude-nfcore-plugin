package nf.plugin.extensions

import org.junit.Test
import static org.junit.Assert.*

/**
 * Unit tests for WorkflowExtension
 */
class WorkflowExtensionTest {

    @Test
    void testCheckResources_Sufficient() {
        assertTrue(WorkflowExtension.checkResources(8, 4, 16, 8))
    }

    @Test
    void testCheckResources_InsufficientMemory() {
        assertFalse(WorkflowExtension.checkResources(32, 4, 16, 8))
    }

    @Test
    void testCheckResources_InsufficientCpus() {
        assertFalse(WorkflowExtension.checkResources(8, 16, 16, 8))
    }

    @Test
    void testParametersSummary() {
        Map params = [
            'param1': 'value1',
            'param2': 'value2',
            '_internal': 'should_be_filtered'
        ]
        Map summary = WorkflowExtension.parametersSummary(params)
        
        assertEquals(2, summary.size())
        assertTrue(summary.containsKey('param1'))
        assertTrue(summary.containsKey('param2'))
        assertFalse(summary.containsKey('_internal'))
    }

    @Test
    void testFormatDuration_Days() {
        String result = WorkflowExtension.formatDuration(172800000L) // 2 days
        assertTrue(result.contains("2d"))
    }

    @Test
    void testFormatDuration_Hours() {
        String result = WorkflowExtension.formatDuration(7200000L) // 2 hours
        assertTrue(result.contains("2h"))
    }

    @Test
    void testFormatDuration_Minutes() {
        String result = WorkflowExtension.formatDuration(120000L) // 2 minutes
        assertTrue(result.contains("2m"))
    }

    @Test
    void testFormatDuration_Seconds() {
        String result = WorkflowExtension.formatDuration(30000L) // 30 seconds
        assertTrue(result.contains("30s"))
    }
}
