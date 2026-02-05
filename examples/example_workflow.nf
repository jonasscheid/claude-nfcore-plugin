#!/usr/bin/env nextflow

/*
 * Example workflow demonstrating nf-claude-nfcore plugin usage
 * 
 * This workflow shows how to use the plugin's validation and workflow utilities
 */

nextflow.enable.dsl=2

// Import plugin extensions (will be available when plugin is loaded)
// import nf.plugin.extensions.ValidationExtension
// import nf.plugin.extensions.WorkflowExtension

// Parameters with validation
params.input = null
params.outdir = './results'
params.max_cpus = 4
params.max_memory = '8.GB'

// Workflow metadata
def workflow_name = 'example-nfcore-workflow'
def workflow_version = '1.0.0'

/*
 * Main workflow
 */
workflow {
    // Log workflow start
    log.info """
    ====================================
    ${workflow_name} v${workflow_version}
    ====================================
    Input file: ${params.input}
    Output dir: ${params.outdir}
    Max CPUs:   ${params.max_cpus}
    Max memory: ${params.max_memory}
    ====================================
    """.stripIndent()
    
    // Validate required parameters
    if (!params.input) {
        error "ERROR: Please provide an input file with --input"
    }
    
    // Create input channel
    input_ch = Channel.fromPath(params.input)
    
    // Run example process
    PROCESS_DATA(input_ch)
    
    // Create output structure
    ORGANIZE_RESULTS(PROCESS_DATA.out)
}

/*
 * Example process using nf-core best practices
 */
process PROCESS_DATA {
    tag "$input_file.name"
    publishDir "${params.outdir}/processed", mode: 'copy'
    
    input:
    path input_file
    
    output:
    path "processed_${input_file.name}"
    
    script:
    """
    echo "Processing ${input_file.name}..."
    echo "Timestamp: \$(date)" > processed_${input_file.name}
    echo "Input: ${input_file.name}" >> processed_${input_file.name}
    echo "Processed with nf-claude-nfcore plugin" >> processed_${input_file.name}
    """
}

/*
 * Example process for organizing results
 */
process ORGANIZE_RESULTS {
    publishDir "${params.outdir}/final", mode: 'copy'
    
    input:
    path processed_file
    
    output:
    path "summary.txt"
    
    script:
    """
    echo "Workflow Summary" > summary.txt
    echo "================" >> summary.txt
    echo "Workflow: ${workflow_name}" >> summary.txt
    echo "Version: ${workflow_version}" >> summary.txt
    echo "Input processed: ${processed_file}" >> summary.txt
    echo "Completion time: \$(date)" >> summary.txt
    """
}

/*
 * Workflow completion handler
 */
workflow.onComplete {
    log.info """
    ====================================
    Workflow completed!
    Status:     ${workflow.success ? 'SUCCESS' : 'FAILED'}
    Duration:   ${workflow.duration}
    Output dir: ${params.outdir}
    ====================================
    """.stripIndent()
}

workflow.onError {
    log.error """
    ====================================
    Workflow execution error!
    Error message: ${workflow.errorMessage}
    ====================================
    """.stripIndent()
}
