# Contributing to H0sty

Thank you for your interest in contributing to H0sty! This document provides guidelines and information for contributors.

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct. Please report unacceptable behavior to [support@h0sty.app](mailto:support@h0sty.app).

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the behavior
- **Expected behavior**
- **Actual behavior**
- **Screenshots** if applicable
- **Environment details** (macOS version, H0sty version, etc.)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Clear title and description** of the enhancement
- **Use case** - explain why this would be useful
- **Detailed description** of the proposed functionality
- **Mockups or examples** if applicable

### Development Setup

1. **Prerequisites**
   - macOS 13.0 (Ventura) or later
   - Xcode 15.0 or later
   - Git

2. **Fork and Clone**
   ```bash
   # Fork the repository on GitHub
   git clone https://github.com/your-username/h0sty.git
   cd h0sty
   ```

3. **Open in Xcode**
   ```bash
   open H0sty.xcodeproj
   ```

4. **Build and Run**
   - Select the "H0sty" scheme
   - Build with ⌘+B
   - Run with ⌘+R

### Development Process

1. **Follow the Planfile**: Our development is structured in phases outlined in the [Planfile](Planfile)
2. **Branch Naming**: Use descriptive branch names
   - `feature/add-entry-grouping`
   - `bugfix/hosts-parsing-issue`
   - `docs/update-readme`

3. **Commit Messages**: Use conventional commits format
   - `feat: add new feature`
   - `fix: resolve bug`
   - `docs: update documentation`
   - `refactor: improve code structure`
   - `test: add or modify tests`

4. **Code Style**
   - Follow Swift naming conventions
   - Use SwiftUI best practices
   - Maintain MVVM architecture
   - Add unit tests for new features
   - Keep code modular and well-commented

### Pull Request Process

1. **Before Submitting**
   - Ensure all tests pass
   - Update documentation if needed
   - Follow the existing code style
   - Add tests for new functionality

2. **Pull Request Template**
   - **Description**: What does this PR do?
   - **Related Issue**: Link to any related issues
   - **Testing**: How was this tested?
   - **Screenshots**: Include screenshots for UI changes
   - **Breaking Changes**: Note any breaking changes

3. **Review Process**
   - All PRs require code review
   - Address feedback promptly
   - Keep PR scope focused and small
   - Squash commits before merging

### Architecture Guidelines

#### MVVM Pattern
- **Models**: Data structures and business logic
- **Views**: SwiftUI views and UI components
- **ViewModels**: Mediate between Models and Views

#### Security Considerations
- All system file modifications must go through the privileged helper tool
- Validate all user input
- Handle errors gracefully
- Never store sensitive information

#### UI/UX Guidelines
- Follow Apple's Human Interface Guidelines
- Support both light and dark modes
- Ensure accessibility compliance
- Use native SwiftUI components
- Maintain consistency with macOS design patterns

### Testing

#### Unit Tests
```bash
# Run all tests
xcodebuild test -project H0sty.xcodeproj -scheme H0sty

# Or use Xcode: Product → Test (⌘+U)
```

#### Integration Tests
- Test the full workflow from UI to system file modification
- Verify helper tool communication
- Test error handling paths

#### Manual Testing
- Test on different macOS versions
- Verify both light and dark mode appearance
- Test with various hosts file configurations
- Validate admin permission workflows

### Documentation

- Update README.md for user-facing changes
- Update REQUIREMENTS.md for technical changes
- Add inline code documentation
- Update CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/) format

### Release Process

1. **Version Bumping**: Follow [Semantic Versioning](https://semver.org/)
   - MAJOR: Breaking changes
   - MINOR: New features, backwards compatible
   - PATCH: Bug fixes, backwards compatible

2. **Changelog**: Update CHANGELOG.md with all changes

3. **Testing**: Comprehensive testing on supported macOS versions

4. **Tagging**: Create git tags for releases
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/jamievanderpijll/h0sty/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jamievanderpijll/h0sty/discussions)
- **Email**: [support@h0sty.app](mailto:support@h0sty.app)

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- About dialog in the app

Thank you for contributing to H0sty! 🚀