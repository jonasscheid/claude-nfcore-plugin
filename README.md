# nf-claude-nfcore Plugin

[![Build and Test](https://github.com/jonasscheid/claude-nfcore-plugin/workflows/Build%20and%20Test/badge.svg)](https://github.com/jonasscheid/claude-nfcore-plugin/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Nextflow plugin implementing nf-core best practices and common workflow patterns. This plugin provides utilities for validation, workflow management, and standardized error handling following nf-core community guidelines.

## Features

### 🔍 Validation Utilities
- **Parameter Validation**: Validate required parameters, types, and ranges
- **File Path Validation**: Ensure input files exist before workflow execution
- **Email Validation**: Validate email addresses with proper format checking
- **Enum Validation**: Restrict parameters to allowed values

### 🔧 Workflow Utilities
- **Resource Management**: Check and manage computational resources
- **Parameter Summaries**: Generate comprehensive parameter reports
- **Output Organization**: Create standardized directory structures
- **Duration Formatting**: Human-readable duration formatting
- **Workflow Logging**: Enhanced start, completion, and error logging

### 📋 nf-core Best Practices
- Follows nf-core community standards
- Comprehensive error handling
- Detailed logging for debugging
- Type-safe function signatures
- Semantic versioning

## Installation

### Using the plugin in your workflow

Add the plugin to your `nextflow.config`:

```groovy
plugins {
    id 'nf-claude-nfcore@0.1.0'
}
```

Or specify it directly in your workflow script:

```groovy
plugins {
    id 'nf-claude-nfcore@0.1.0'
}
```

## Usage

### Parameter Validation

```groovy
import nf.plugin.extensions.ValidationExtension

// Validate required parameters
ValidationExtension.validateRequired(params.input, 'input')

// Validate file paths
ValidationExtension.validateFilePath(params.input, 'input')

// Validate ranges
ValidationExtension.validateRange(params.threads, 1, 32, 'threads')

// Validate enum values
ValidationExtension.validateEnum(params.mode, ['strict', 'lenient'], 'mode')

// Validate email addresses
ValidationExtension.validateEmail(params.email, 'email')
```

### Workflow Management

```groovy
import nf.plugin.extensions.WorkflowExtension

// Check available resources
WorkflowExtension.checkResources(16, 8, 64, 32)

// Generate parameter summary
def summary = WorkflowExtension.parametersSummary(params)

// Log workflow start
WorkflowExtension.logWorkflowStart('my-workflow', '1.0.0')

// Create output directory structure
def dirs = WorkflowExtension.createOutputStructure(
    params.outdir, 
    ['processed', 'qc', 'reports']
)

// Format duration
def duration = WorkflowExtension.formatDuration(workflow.duration.toMillis())

// Log workflow completion
WorkflowExtension.logWorkflowComplete('my-workflow', workflow.success)
```

## Examples

See the [examples](examples/) directory for complete workflow examples demonstrating plugin usage.

To run the example workflow:

```bash
# Create test data
echo "Test data" > test_data.txt

# Run the workflow
nextflow run examples/example_workflow.nf --input test_data.txt
```

## Building from Source

### Requirements
- JDK 11 or higher
- Gradle 7.0 or higher

### Build the plugin

```bash
# Clone the repository
git clone https://github.com/jonasscheid/claude-nfcore-plugin.git
cd claude-nfcore-plugin

# Build the plugin
gradle build

# Run tests
gradle test
```

## Development

### Project Structure

```
claude-nfcore-plugin/
├── src/
│   ├── main/
│   │   └── groovy/
│   │       └── nf/
│   │           └── plugin/
│   │               ├── NfCorePlugin.groovy
│   │               └── extensions/
│   │                   ├── ValidationExtension.groovy
│   │                   └── WorkflowExtension.groovy
│   └── test/
│       └── groovy/
│           └── nf/
│               └── plugin/
│                   └── extensions/
├── examples/
│   ├── example_workflow.nf
│   └── README.md
├── build.gradle
├── settings.gradle
├── nextflow.config
└── README.md
```

### Running Tests

```bash
gradle test
```

### Code Style

This project follows nf-core code style guidelines:
- Use meaningful variable names
- Add JavaDoc comments to all public methods
- Follow Groovy naming conventions
- Keep methods focused and concise

## Configuration

The plugin provides default configurations in `nextflow.config` that follow nf-core best practices:

- **Resource limits**: Configurable max memory, CPUs, and time
- **Error handling**: Automatic retry on common error codes
- **Reporting**: Timeline, report, trace, and DAG generation
- **Profiles**: Debug, test, docker, and singularity profiles

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your code:
- Follows nf-core style guidelines
- Includes appropriate tests
- Updates documentation as needed
- Passes all CI checks

## Versioning

This project uses [Semantic Versioning](https://semver.org/). For available versions, see the [tags on this repository](https://github.com/jonasscheid/claude-nfcore-plugin/tags).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [nf-core](https://nf-co.re/) community for best practices and guidelines
- [Nextflow](https://www.nextflow.io/) team for the amazing workflow framework

## Support

For issues, questions, or contributions:
- Open an [issue](https://github.com/jonasscheid/claude-nfcore-plugin/issues)
- Check the [examples](examples/) directory for usage patterns
- Review [nf-core documentation](https://nf-co.re/docs)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes in each version.