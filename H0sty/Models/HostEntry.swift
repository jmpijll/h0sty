import Foundation

/// A model representing a single entry in the hosts file
struct HostEntry: Identifiable, Hashable {
    let id = UUID()
    let ip: String
    let hostname: String
    let isEnabled: Bool
    let comment: String?
    let originalLine: String
    
    init(ip: String, hostname: String, isEnabled: Bool = true, comment: String? = nil, originalLine: String) {
        self.ip = ip
        self.hostname = hostname
        self.isEnabled = isEnabled
        self.comment = comment
        self.originalLine = originalLine
    }
    
    /// Creates a HostEntry by parsing a line from the hosts file
    static func parse(from line: String) -> HostEntry? {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        
        // Skip empty lines
        guard !trimmedLine.isEmpty else { return nil }
        
        let isEnabled = !trimmedLine.hasPrefix("#")
        let workingLine = isEnabled ? trimmedLine : String(trimmedLine.dropFirst()).trimmingCharacters(in: .whitespaces)
        
        // Split line into components
        let components = workingLine.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        // Need at least IP and hostname
        guard components.count >= 2 else { return nil }
        
        let ip = components[0]
        let hostname = components[1]
        
        // Extract comment if present
        var comment: String?
        if let commentIndex = workingLine.firstIndex(of: "#") {
            comment = String(workingLine[commentIndex...]).trimmingCharacters(in: .whitespaces)
        }
        
        return HostEntry(
            ip: ip,
            hostname: hostname,
            isEnabled: isEnabled,
            comment: comment,
            originalLine: line
        )
    }
    
    /// Returns the display name for the host entry
    var displayName: String {
        return hostname
    }
    
    /// Returns the formatted display text for the entry
    var displayText: String {
        return "\(ip) → \(hostname)"
    }
}

/// Sample data for previews and testing
extension HostEntry {
    static let sampleData: [HostEntry] = [
        HostEntry(ip: "127.0.0.1", hostname: "localhost", isEnabled: true, originalLine: "127.0.0.1 localhost"),
        HostEntry(ip: "::1", hostname: "localhost", isEnabled: true, originalLine: "::1 localhost"),
        HostEntry(ip: "127.0.0.1", hostname: "local.dev", isEnabled: true, originalLine: "127.0.0.1 local.dev"),
        HostEntry(ip: "192.168.1.100", hostname: "my-server.local", isEnabled: false, originalLine: "# 192.168.1.100 my-server.local"),
        HostEntry(ip: "0.0.0.0", hostname: "ads.example.com", isEnabled: true, comment: "# Block ads", originalLine: "0.0.0.0 ads.example.com # Block ads")
    ]
}