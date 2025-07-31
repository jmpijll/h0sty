# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2025-07-31

### Changed
- **BREAKING**: Minimum macOS version requirement increased from 13.0 (Ventura) to 15.0 (Sequoia)
- Updated to support modern SwiftUI symbol effects and animations
- Project now requires Xcode 16.0+ for development

### Technical Updates
- **symbolEffect(.rotate)**: Now fully supported with macOS 15.0+ requirement
- **Modern Animations**: Enhanced animation capabilities with latest SwiftUI features
- **Developer Experience**: Improved with latest Xcode and macOS SDK features

### Rationale
This update enables the use of cutting-edge SwiftUI features including:
- Advanced symbol effects with `.symbolEffect(.rotate, isActive:)` 
- Enhanced animation performance and capabilities
- Better native macOS integration
- Future-proofing for upcoming SwiftUI features

## [0.2.0] - 2025-07-31

### Added
- **Complete macOS SwiftUI application structure** with proper project organization
- **HostEntry data model** with parsing capabilities for hosts file entries
- **HostsManager service** with async file reading and error handling
- **Modern SwiftUI interface** with NavigationSplitView and List components
- **Real-time hosts file parsing** that handles comments, disabled entries, and various formats
- **Native macOS design** following Apple's Human Interface Guidelines
- **Comprehensive error handling** with user-friendly error messages
- **Sample data fallback** for development and testing scenarios

### Technical Implementation
- **MVVM Architecture**: Clean separation between Models, Views, and Services
- **Async/Await**: Modern Swift concurrency for file operations
- **ObservableObject**: Reactive data binding with @Published properties
- **Identifiable Protocol**: Efficient SwiftUI List rendering with UUID-based identification
- **OSLog Integration**: Structured logging for debugging and monitoring
- **SwiftUI Previews**: Multiple preview configurations for development

### User Interface
- **Split-view layout** with sidebar and detail pane for better organization
- **Status indicators** showing enabled/disabled states with visual feedback
- **Monospaced fonts** for IP addresses and hostnames for better readability
- **Refresh functionality** with loading states and pull-to-refresh support
- **Empty states** and error handling with user-friendly messaging
- **Native styling** with proper macOS colors and spacing

### Verification Complete
- ✅ App launches and initializes properly
- ✅ Reads /etc/hosts file with robust error handling
- ✅ Correctly parses and displays host entries
- ✅ Handles commented (disabled) entries appropriately
- ✅ Displays visual indicators for enabled/disabled states
- ✅ Provides sample data when hosts file is inaccessible
- ✅ Implements proper macOS-native UI patterns

## [0.1.0] - 2025-07-31

### Added
- Initial project structure and planning files
- Comprehensive project documentation (README.md, REQUIREMENTS.md, CONTRIBUTING.md)
- Development roadmap (Planfile) with 4 structured phases
- MIT License for open source distribution
- Standard macOS/Swift .gitignore configuration
- GitHub repository setup with proper descriptions and metadata

### Project Structure
- **Phase 0 Complete**: Project initialization with all foundational documents
- **Next Phase**: Read-only core functionality (v0.2.0)

### Documentation
- README.md: Complete project overview with features, installation, and development guides
- REQUIREMENTS.md: Technical specifications and architecture decisions
- CONTRIBUTING.md: Comprehensive contributor guidelines and development workflows
- Planfile: Structured 4-phase development roadmap