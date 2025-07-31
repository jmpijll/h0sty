import SwiftUI

/// Main view for displaying the list of host entries
struct HostsListView: View {
    @StateObject private var hostsManager = HostsManager()
    @State private var showingAddEntry = false
    @State private var showingDeleteConfirmation = false
    @State private var entryToDelete: HostEntry?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with statistics
            headerView
            
            // Main content
            Group {
                if hostsManager.isLoading {
                    loadingView
                } else if let errorMessage = hostsManager.errorMessage {
                    errorView(errorMessage)
                } else if hostsManager.hostEntries.isEmpty {
                    emptyStateView
                } else {
                    hostsList
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .navigationTitle("H0sty")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("Add Entry", systemImage: "plus") {
                    showingAddEntry = true
                }
                .disabled(hostsManager.isLoading)
                .help("Add a new host entry")
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button("Refresh", systemImage: "arrow.clockwise") {
                    hostsManager.refresh()
                }
                .disabled(hostsManager.isLoading)
                .help("Refresh hosts file")
                .symbolEffect(.rotate, isActive: hostsManager.isLoading)
            }
        }
        .sheet(isPresented: $showingAddEntry) {
            AddHostEntryView()
                .environmentObject(hostsManager)
        }
        .alert("Delete Host Entry", isPresented: $showingDeleteConfirmation, presenting: entryToDelete) { entry in
            Button("Delete", role: .destructive) {
                deleteEntry(entry)
            }
            Button("Cancel", role: .cancel) { }
        } message: { entry in
            Text("Are you sure you want to delete '\(entry.hostname)'? This action cannot be undone.")
        }
        .alert("Error", isPresented: .constant(hostsManager.lastError != nil), presenting: hostsManager.lastError) { _ in
            Button("OK") {
                hostsManager.lastError = nil
            }
        } message: { error in
            VStack(alignment: .leading) {
                Text(error.errorDescription ?? "An unknown error occurred")
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                }
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hosts File Entries")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(hostsManager.enabledEntriesCount) enabled • \(hostsManager.disabledEntriesCount) disabled")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status indicator
            Image(systemName: hostsManager.isLoading ? "arrow.clockwise" : "checkmark.circle.fill")
                .foregroundColor(hostsManager.isLoading ? .orange : .green)
                .symbolEffect(.rotate, isActive: hostsManager.isLoading)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Content Views
    
    private var hostsList: some View {
        List(hostsManager.hostEntries) { entry in
            HostEntryRow(entry: entry) {
                // Toggle action
                toggleEntry(entry)
            } deleteAction: {
                // Delete action
                entryToDelete = entry
                showingDeleteConfirmation = true
            }
        }
        .listStyle(.plain)
        .refreshable {
            hostsManager.refresh()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading hosts file...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.headline)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                hostsManager.refresh()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Host Entries")
                .font(.headline)
            
            Text("The hosts file appears to be empty or contains no valid entries.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Refresh") {
                hostsManager.refresh()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    // MARK: - Action Methods
    
    private func toggleEntry(_ entry: HostEntry) {
        Task {
            do {
                try await hostsManager.toggleEntry(entry)
            } catch {
                // Error handling is done through hostsManager.lastError
            }
        }
    }
    
    private func deleteEntry(_ entry: HostEntry) {
        Task {
            do {
                try await hostsManager.deleteEntry(entry)
            } catch {
                // Error handling is done through hostsManager.lastError
            }
        }
    }
}

// MARK: - Host Entry Row

struct HostEntryRow: View {
    let entry: HostEntry
    let toggleAction: () -> Void
    let deleteAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Toggle button (status indicator)
            Button(action: toggleAction) {
                Circle()
                    .fill(entry.isEnabled ? .green : .gray)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(entry.isEnabled ? .green : .gray, lineWidth: 1)
                            .opacity(0.3)
                    )
            }
            .buttonStyle(.plain)
            .help(entry.isEnabled ? "Click to disable" : "Click to enable")
            
            VStack(alignment: .leading, spacing: 2) {
                // Hostname (primary text)
                Text(entry.hostname)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(entry.isEnabled ? .primary : .secondary)
                
                // IP address (secondary text)
                Text(entry.ip)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                
                // Comment if present
                if let comment = entry.comment, !comment.isEmpty {
                    Text("# \(comment)")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.7))
                        .italic()
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                // Status label
                Text(entry.isEnabled ? "Enabled" : "Disabled")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(entry.isEnabled ? .green.opacity(0.2) : .gray.opacity(0.2))
                    .foregroundColor(entry.isEnabled ? .green : .gray)
                    .clipShape(Capsule())
                
                // Delete button
                Button(action: deleteAction) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Delete this entry")
            }
        }
        .padding(.vertical, 4)
        .opacity(entry.isEnabled ? 1.0 : 0.6)
        .contextMenu {
            Button(entry.isEnabled ? "Disable" : "Enable", systemImage: entry.isEnabled ? "minus.circle" : "plus.circle") {
                toggleAction()
            }
            
            Divider()
            
            Button("Copy IP Address", systemImage: "doc.on.doc") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(entry.ip, forType: .string)
            }
            
            Button("Copy Hostname", systemImage: "doc.on.doc") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(entry.hostname, forType: .string)
            }
            
            Divider()
            
            Button("Delete", systemImage: "trash", role: .destructive) {
                deleteAction()
            }
        }
    }
}

// MARK: - Previews

#Preview("Hosts List") {
    HostsListView()
        .frame(width: 600, height: 500)
}

#Preview("Host Entry Row - Enabled") {
    HostEntryRow(entry: HostEntry.sampleData[0]) {
        // Toggle action
    } deleteAction: {
        // Delete action
    }
    .padding()
}

#Preview("Host Entry Row - Disabled") {
    HostEntryRow(entry: HostEntry.sampleData[3]) {
        // Toggle action
    } deleteAction: {
        // Delete action
    }
    .padding()
}