import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            // Sidebar - for future phases, currently minimal
            VStack(alignment: .leading, spacing: 16) {
                Label("Host Entries", systemImage: "list.bullet")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Read-Only Mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Viewing hosts file contents. Editing capabilities coming in Phase 2.")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding()
            .frame(minWidth: 200)
            .background(Color(NSColor.controlBackgroundColor))
        } detail: {
            HostsListView()
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
}

#Preview {
    ContentView()
        .frame(width: 900, height: 600)
}