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

## [0.5.0] - 2025-07-31

### Added
- **Privileged Helper Tool**: Complete SMJobBless implementation for secure system-level operations
- **XPC Communication**: Secure inter-process communication between main app and helper tool
- **Real File Operations**: Actual /etc/hosts file modification with proper permissions and backup
- **Helper Tool Installation**: Automatic installation with user authorization prompt
- **Advanced Error Handling**: Comprehensive error reporting with recovery suggestions
- **Security Implementation**: Code signing requirements and XPC connection validation

### Changed
- **BREAKING**: Hosts file operations now require administrator privileges for the first run
- **Enhanced UI**: Add, delete, and toggle operations now work with actual file system
- **Improved Reliability**: Operations are performed by privileged helper tool with proper error handling
- **Better User Experience**: Clear prompts for permission escalation when needed

### Technical Implementation
- **XPC Protocol**: `HostsXPCProtocol` defining secure communication interface
- **Helper Tool**: `com.h0sty.H0sty.HostsHelper` privileged daemon for file operations
- **Authorization**: Integration with macOS Security framework for user consent
- **File Safety**: Automatic backup creation before hosts file modification
- **Modern Swift**: Async/await patterns for all privileged operations

### Developer Notes
- Helper tool uses launchd for lifecycle management
- Code signing requirements enforce app-helper trust relationship
- XPC communication provides secure, sandboxed privilege escalation
- Follows Apple's recommended security practices for privileged operations

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
- **Statistics display** showing counts of enabled/disabled entries
- **Visual indicators** for entry status with color-coded display
- **Loading states** with proper async data handling
- **Error states** with actionable user feedback
- **Empty states** with helpful guidance for new users

### Developer Experience
- **Modular architecture** making it easy to add features
- **Comprehensive logging** for debugging and monitoring
- **Sample data** for development without requiring actual hosts file
- **Error simulation** for testing various failure scenarios
- **Preview support** for rapid UI development and testing

### Quality Assurance
- **Robust parsing** handles various hosts file formats and edge cases
- **Memory efficient** with proper data lifecycle management
- **Thread safe** operations with MainActor usage
- **Performance optimized** with efficient string parsing algorithms

## [0.1.0] - 2025-07-31

### Added
- **Project Foundation**: Complete Xcode project setup with macOS 15.0+ target
- **Planning Documentation**: 
  - Comprehensive `Planfile` outlining 4-phase development approach
  - Detailed `REQUIREMENTS.md` serving as technical constitution
  - `CHANGELOG.md` following "Keep a Changelog" format
- **Open Source Setup**: MIT License and comprehensive README
- **Development Workflow**: Git repository with proper .gitignore
- **Contributing Guidelines**: Detailed contribution process and standards

### Technical Setup
- **macOS Application**: SwiftUI-based native macOS app targeting macOS 15.0+
- **Architecture**: MVVM pattern with clean separation of concerns
- **Build System**: Xcode 16.0+ with modern Swift 5.x
- **Security Foundation**: Prepared for SMJobBless privileged operations
- **Documentation**: Comprehensive project structure and development guidelines

### Project Structure
- **Modular Design**: Organized codebase with clear separation between Models, Views, and Services
- **Scalable Architecture**: Foundation ready for privileged operations and complex features
- **Development Standards**: Established coding conventions and project organization
- **Quality Processes**: Structured approach to testing, documentation, and releases