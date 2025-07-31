import SwiftUI

/// Main view for displaying the list of host entries
struct HostsListView: View {
    @StateObject private var hostsManager = HostsManager()
    
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
            ToolbarItem(placement: .primaryAction) {
                Button("Refresh", systemImage: "arrow.clockwise") {
                    hostsManager.refresh()
                }
                .disabled(hostsManager.isLoading)
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
            HostEntryRow(entry: entry)
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
}

// MARK: - Host Entry Row

struct HostEntryRow: View {
    let entry: HostEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(entry.isEnabled ? .green : .gray)
                .frame(width: 8, height: 8)
            
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
                    Text(comment)
                        .font(.caption)
                        .foregroundColor(.tertiary)
                        .italic()
                }
            }
            
            Spacer()
            
            // Enabled/Disabled label
            Text(entry.isEnabled ? "Enabled" : "Disabled")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(entry.isEnabled ? .green.opacity(0.2) : .gray.opacity(0.2))
                .foregroundColor(entry.isEnabled ? .green : .gray)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
        .opacity(entry.isEnabled ? 1.0 : 0.6)
    }
}

// MARK: - Previews

#Preview("Hosts List") {
    HostsListView()
        .frame(width: 600, height: 500)
}

#Preview("Host Entry Row - Enabled") {
    HostEntryRow(entry: HostEntry.sampleData[0])
        .padding()
}

#Preview("Host Entry Row - Disabled") {
    HostEntryRow(entry: HostEntry.sampleData[3])
        .padding()
}