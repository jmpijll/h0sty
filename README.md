# H0sty

<div align="center">

![H0sty Logo](docs/images/h0sty-logo.png)

**A beautiful, minimal, and powerful macOS app to manage your system's hosts file**

[![Swift 5.x](https://img.shields.io/badge/Swift-5.x-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-blue.svg)](https://developer.apple.com/xcode/swiftui/)
[![macOS 15.0+](https://img.shields.io/badge/macOS-15.0+-black.svg)](https://www.apple.com/macos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/jamievanderpijll/h0sty.svg)](https://github.com/jamievanderpijll/h0sty/releases)

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Development](#development) • [Contributing](#contributing)

</div>

## Overview

H0sty is a native macOS application that provides an intuitive, secure way to manage your system's `/etc/hosts` file. Built with Swift and SwiftUI, it combines the power of command-line hosts file management with a beautiful, user-friendly interface that feels right at home on macOS.

## Features

### ✨ Core Functionality
- **📋 View Hosts**: Clean, readable display of your current hosts file entries
- **➕ Add Entries**: Simple interface to add new IP-hostname pairs
- **🗑️ Delete Entries**: Remove unwanted entries with a single click
- **🔄 Toggle Entries**: Enable/disable entries by commenting/uncommenting (no data loss)
- **🎨 Syntax Highlighting**: Color-coded display for IPs, hostnames, and comments

### 🚀 Advanced Features
- **📁 Entry Grouping**: Organize related entries and toggle entire groups
- **✏️ Inline Editing**: Double-click any entry to edit directly in the list
- **🔧 Advanced Mode**: Raw text editor with syntax highlighting for power users
- **⚙️ Preferences**: Customizable settings for launch options and UI preferences

### 🔒 Security & Reliability
- **🛡️ Secure Privilege Escalation**: Uses macOS `SMJobBless` API for secure system file access
- **🔐 No Root Required**: Never asks you to run the app as administrator
- **💾 Safe Modifications**: All changes are validated and can be easily reverted
- **🎯 Minimal Permissions**: Only requests admin privileges when necessary

### 🎨 Native macOS Experience
- **🌙 Dark Mode Support**: Full support for macOS light and dark themes
- **💫 Native UI**: Built with SwiftUI following Apple's Human Interface Guidelines
- **⚡ Performance**: Lightweight and responsive, built for efficiency
- **🔄 Live Updates**: Real-time reflection of changes across all views

## Requirements

- **macOS**: 15.0 (Sequoia) or later
- **Architecture**: Intel (x86_64) and Apple Silicon (arm64) supported

## Installation

### Download from Releases (Recommended)
1. Go to the [Releases](https://github.com/jamievanderpijll/h0sty/releases) page
2. Download the latest `H0sty.dmg` file
3. Open the DMG and drag H0sty to your Applications folder
4. Launch H0sty from Applications or Spotlight

### Build from Source
```bash
# Clone the repository
git clone https://github.com/jamievanderpijll/h0sty.git
cd h0sty

# Open in Xcode
open H0sty.xcodeproj

# Build and run (⌘+R)
```

## Usage

### First Launch
1. **Launch H0sty** from Applications or Spotlight
2. **Grant Permissions**: On first use, H0sty will request administrator privileges to install a secure helper tool
3. **View Your Hosts**: The app will display your current hosts file entries

### Managing Entries

#### Adding a New Entry
1. Click the **"+"** button or use **⌘+N**
2. Enter the IP address (e.g., `127.0.0.1`)
3. Enter the hostname (e.g., `local.example.com`)
4. Click **"Add"** or press **Enter**

#### Editing an Entry
- **Double-click** any entry to edit it inline
- **Right-click** for additional options
- Changes are saved automatically

#### Disabling/Enabling Entries
- **Toggle Switch**: Click the toggle to enable/disable an entry
- **Disabled entries** are commented out in the hosts file but preserved

#### Grouping Entries
1. Click **"New Group"** to create a group
2. **Drag entries** into the group
3. Use the **group toggle** to enable/disable all entries at once

### Advanced Mode
- **View → Advanced Mode** or **⌘+Shift+A**
- Edit the hosts file as raw text with syntax highlighting
- Changes sync automatically with the main list view

## Development

H0sty is built with modern Swift and SwiftUI, following a clean, modular architecture.

### Technology Stack
- **Language**: Swift 5.x
- **UI Framework**: SwiftUI with AppKit integration where needed
- **Architecture**: MVVM (Model-View-ViewModel)
- **Security**: SMJobBless privileged helper tool
- **Target**: macOS 15.0+

### Project Structure
```
H0sty/
├── H0sty/                  # Main application target
│   ├── Models/             # Data models and business logic
│   ├── Views/              # SwiftUI views and UI components
│   ├── ViewModels/         # View models (MVVM pattern)
│   ├── Services/           # Core services (HostsManager, etc.)
│   └── Resources/          # Assets, localizations, etc.
├── H0styHelper/            # Privileged helper tool target
├── Shared/                 # Shared code between targets
└── Tests/                  # Unit and integration tests
```

### Building
1. **Prerequisites**: Xcode 16.0+ and macOS 15.0+
2. **Clone**: `git clone https://github.com/jamievanderpijll/h0sty.git`
3. **Open**: `open H0sty.xcodeproj`
4. **Build**: Select "H0sty" scheme and build (⌘+B)

### Testing
```bash
# Run unit tests
xcodebuild test -project H0sty.xcodeproj -scheme H0sty

# Or use Xcode
# Product → Test (⌘+U)
```

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Process
1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Follow** the development phases outlined in the [Planfile](Planfile)
4. **Commit** your changes: `git commit -m 'feat: Add amazing feature'`
5. **Push** to the branch: `git push origin feature/amazing-feature`
6. **Open** a Pull Request

### Code Style
- Follow Swift naming conventions
- Use SwiftUI best practices
- Maintain MVVM architecture
- Add unit tests for new features
- Update documentation as needed

## Roadmap

See the [Planfile](Planfile) for detailed development phases:

- **Phase 0**: ✅ Project initialization and planning
- **Phase 1**: ✅ Read-only core functionality
- **Phase 2**: 📋 Core editing functionality
- **Phase 3**: 🎨 UI/UX refinement and advanced features
- **Phase 4**: 🚀 Advanced mode and v1.0.0 release

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Apple's [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- The Swift and SwiftUI communities
- All contributors who help make H0sty better

## Support

- **Issues**: [GitHub Issues](https://github.com/jamievanderpijll/h0sty/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jamievanderpijll/h0sty/discussions)
- **Email**: [support@h0sty.app](mailto:support@h0sty.app)

---

<div align="center">
Made with ❤️ for the macOS community
</div>