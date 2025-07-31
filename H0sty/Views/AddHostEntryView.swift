import SwiftUI

/// View for adding a new host entry
struct AddHostEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var hostsManager: HostsManager
    
    @State private var ipAddress = ""
    @State private var hostname = ""
    @State private var comment = ""
    @State private var isEnabled = true
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var isFormValid: Bool {
        !ipAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !hostname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidIPAddress(ipAddress.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Host Entry Details") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("IP Address")
                            .font(.headline)
                        TextField("e.g., 127.0.0.1 or ::1", text: $ipAddress)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hostname")
                            .font(.headline)
                        TextField("e.g., example.com", text: $hostname)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comment (Optional)")
                            .font(.headline)
                        TextField("e.g., Development server", text: $comment)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                Section("Options") {
                    Toggle("Enabled", isOn: $isEnabled)
                        .help("Whether this entry should be active in the hosts file")
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Host Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addEntry()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .disabled(isLoading)
        }
        .alert("Error Adding Entry", isPresented: .constant(errorMessage != nil), presenting: errorMessage) { _ in
            Button("OK") {
                errorMessage = nil
            }
        } message: { error in
            Text(error)
        }
    }
    
    private func addEntry() {
        let entry = HostEntry(
            ip: ipAddress.trimmingCharacters(in: .whitespacesAndNewlines),
            hostname: hostname.trimmingCharacters(in: .whitespacesAndNewlines),
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : comment.trimmingCharacters(in: .whitespacesAndNewlines),
            isEnabled: isEnabled
        )
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await hostsManager.addEntry(entry)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    if let hostsError = error as? HostsManagerError {
                        errorMessage = hostsError.errorDescription
                    } else {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func isValidIPAddress(_ ip: String) -> Bool {
        // Basic IP validation - IPv4 and IPv6
        let ipv4Pattern = #"^(\d{1,3}\.){3}\d{1,3}$"#
        let ipv6Pattern = #"^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$|^::1$|^::$"#
        
        let ipv4Regex = try? NSRegularExpression(pattern: ipv4Pattern)
        let ipv6Regex = try? NSRegularExpression(pattern: ipv6Pattern)
        
        let range = NSRange(location: 0, length: ip.utf16.count)
        
        if let ipv4Regex = ipv4Regex, ipv4Regex.firstMatch(in: ip, options: [], range: range) != nil {
            // Validate IPv4 octets are <= 255
            let octets = ip.split(separator: ".").compactMap { Int($0) }
            return octets.count == 4 && octets.allSatisfy { $0 >= 0 && $0 <= 255 }
        }
        
        if let ipv6Regex = ipv6Regex, ipv6Regex.firstMatch(in: ip, options: [], range: range) != nil {
            return true
        }
        
        // Allow some common special cases
        return ["0.0.0.0", "localhost"].contains(ip)
    }
}

#Preview {
    AddHostEntryView()
        .environmentObject(HostsManager())
}