# H0sty Project Requirements

This document outlines the technical requirements, stack, and constraints for the H0sty macOS application.

## 1. Technology Stack

* **Language:** Swift 5.x
* **UI Framework:** SwiftUI for the main interface, utilizing AppKit where necessary for advanced integrations.
* **Target OS:** macOS 13.0 (Ventura) and later.
* **Architecture:** A modular architecture (e.g., MVVM) to separate concerns (UI, business logic, data).

## 2. Core Features

* **View Hosts:** Display the current contents of `/etc/hosts` in a clear, readable list.
* **Add Entry:** A simple UI to add a new IP-hostname pair.
* **Delete Entry:** The ability to remove an existing entry.
* **Toggle Entry:** The ability to comment/uncomment an entry to enable/disable it without deleting it.
* **Grouping (Advanced):** Allow users to group multiple entries together and enable/disable the entire group at once.
* **Syntax Highlighting:** Display comments, IPs, and hostnames in different colors for readability.

## 3. UI/UX Philosophy

* **Simplicity:** The main view should be a clean list of host entries.
* **Native Components:** Strictly use native macOS SwiftUI components.
* **Feedback:** Provide clear visual feedback for actions (e.g., saving, errors).
* **Advanced Mode:** An optional, separate view or mode that allows for raw text editing of the hosts file for power users.

## 4. Security & Permissions

* **Privilege Escalation:** The app must not require the user to run it as root. To gain write permissions for `/etc/hosts`, the app will use a privileged helper tool installed via `SMJobBless`. This is the modern, secure way to handle privilege escalation on macOS. The main app will remain sandboxed if possible, communicating with the helper tool to perform file modifications.
* **User Consent:** The user must be prompted for an administrator password via the standard macOS security dialog only when necessary to install or update the helper tool or modify the hosts file.

## 5. Development Workflow

* **Source Control:** Git.
* **Repository:** The project will be hosted on GitHub.
* **Changelog:** All changes will be logged in `CHANGELOG.md` following the "Keep a Changelog" format.
* **Testing:** Each step in the `Planfile` must result in a testable state.