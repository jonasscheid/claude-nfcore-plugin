package nf.plugin.extensions

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j

/**
 * Workflow utilities following nf-core best practices
 * 
 * Provides helper methods for common workflow patterns:
 * - Resource checking
 * - Channel manipulation
 * - Error handling
 * - Progress tracking
 */
@Slf4j
@CompileStatic
class WorkflowExtension {
    
    /**
     * Check if sufficient resources are available
     * 
     * @param requiredMemory Required memory in GB
     * @param requiredCpus Required number of CPUs
     * @param maxMemory Maximum available memory in GB
     * @param maxCpus Maximum available CPUs
     * @return true if resources are sufficient
     */
    static boolean checkResources(int requiredMemory, int requiredCpus, int maxMemory, int maxCpus) {
        if (requiredMemory > maxMemory) {
            log.warn("Required memory (${requiredMemory}GB) exceeds maximum available (${maxMemory}GB)")
            return false
        }
        if (requiredCpus > maxCpus) {
            log.warn("Required CPUs (${requiredCpus}) exceeds maximum available (${maxCpus})")
            return false
        }
        log.debug("Resource check passed: ${requiredMemory}GB memory, ${requiredCpus} CPUs")
        return true
    }
    
    /**
     * Create a summary map of workflow parameters
     * 
     * @param params The params map from Nextflow
     * @return Map of parameter summaries
     */
    static Map<String, String> parametersSummary(Map params) {
        Map<String, String> summary = [:]
        params.each { key, value ->
            if (value != null && !key.startsWith('_')) {
                summary[key] = value.toString()
            }
        }
        log.info("Generated parameters summary with ${summary.size()} entries")
        return summary
    }
    
    /**
     * Log workflow start information
     * 
     * @param workflowName Name of the workflow
     * @param version Version of the workflow
     */
    static void logWorkflowStart(String workflowName, String version) {
        log.info("=" * 60)
        log.info("Starting workflow: ${workflowName}")
        log.info("Version: ${version}")
        log.info("=" * 60)
    }
    
    /**
     * Log workflow completion information
     * 
     * @param workflowName Name of the workflow
     * @param success Whether the workflow completed successfully
     */
    static void logWorkflowComplete(String workflowName, boolean success) {
        log.info("=" * 60)
        if (success) {
            log.info("Workflow '${workflowName}' completed successfully!")
        } else {
            log.error("Workflow '${workflowName}' failed!")
        }
        log.info("=" * 60)
    }
    
    /**
     * Create standardized output directory structure
     * 
     * @param baseDir Base output directory
     * @param subdirs List of subdirectories to create
     * @return Map of created directories
     */
    static Map<String, File> createOutputStructure(String baseDir, List<String> subdirs) {
        Map<String, File> dirs = [:]
        File base = new File(baseDir)
        
        if (!base.exists()) {
            base.mkdirs()
            log.info("Created base output directory: ${baseDir}")
        }
        
        subdirs.each { subdir ->
            File dir = new File(base, subdir)
            if (!dir.exists()) {
                dir.mkdirs()
                log.debug("Created subdirectory: ${subdir}")
            }
            dirs[subdir] = dir
        }
        
        log.info("Output directory structure created with ${subdirs.size()} subdirectories")
        return dirs
    }
    
    /**
     * Format duration for human-readable output
     * 
     * @param millis Duration in milliseconds
     * @return Formatted duration string
     */
    static String formatDuration(long millis) {
        long seconds = millis / 1000
        long minutes = seconds / 60
        long hours = minutes / 60
        long days = hours / 24
        
        if (days > 0) {
            return "${days}d ${hours % 24}h ${minutes % 60}m"
        } else if (hours > 0) {
            return "${hours}h ${minutes % 60}m ${seconds % 60}s"
        } else if (minutes > 0) {
            return "${minutes}m ${seconds % 60}s"
        } else {
            return "${seconds}s"
        }
    }
}
