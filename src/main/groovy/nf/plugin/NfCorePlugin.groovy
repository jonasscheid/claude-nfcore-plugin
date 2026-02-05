package nf.plugin

import groovy.transform.CompileStatic
import org.pf4j.Plugin
import org.pf4j.PluginWrapper

/**
 * nf-claude-nfcore Plugin
 * 
 * A Nextflow plugin implementing nf-core best practices and common workflows.
 * This plugin provides utilities for:
 * - Schema validation
 * - Parameter checking
 * - Enhanced logging and error handling
 * - File path validation
 * - Common workflow patterns
 * 
 * @author nf-core community
 */
@CompileStatic
class NfCorePlugin extends Plugin {

    NfCorePlugin(PluginWrapper wrapper) {
        super(wrapper)
    }

    @Override
    void start() {
        log.info("Starting nf-claude-nfcore plugin v${wrapper.descriptor.version}")
        log.debug("Plugin loaded successfully with nf-core best practices")
    }

    @Override
    void stop() {
        log.info("Stopping nf-claude-nfcore plugin")
    }
}
