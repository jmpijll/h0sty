import Foundation
import OSLog

/// Service responsible for reading and managing the hosts file
@MainActor
class HostsManager: ObservableObject {
    @Published var hostEntries: [HostEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let logger = Logger(subsystem: "com.h0sty.H0sty", category: "HostsManager")
    private let hostsFilePath = "/etc/hosts"
    
    init() {
        loadHostsFile()
    }
    
    /// Loads the hosts file and parses its contents
    func loadHostsFile() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let entries = try await readHostsFile()
                await MainActor.run {
                    self.hostEntries = entries
                    self.isLoading = false
                    self.logger.info("Successfully loaded \(entries.count) host entries")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to read hosts file: \(error.localizedDescription)"
                    self.isLoading = false
                    self.logger.error("Failed to load hosts file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Reads the hosts file from disk (async to avoid blocking UI)
    private func readHostsFile() async throws -> [HostEntry] {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let fileContent: String
                    
                    // Try to read the actual hosts file first
                    if FileManager.default.fileExists(atPath: self.hostsFilePath) {
                        fileContent = try String(contentsOfFile: self.hostsFilePath, encoding: .utf8)
                    } else {
                        // Fallback to sample data for development/testing
                        fileContent = self.sampleHostsContent()
                        self.logger.warning("Hosts file not found, using sample data")
                    }
                    
                    let entries = self.parseHostsContent(fileContent)
                    continuation.resume(returning: entries)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Parses the raw hosts file content into HostEntry objects
    private func parseHostsContent(_ content: String) -> [HostEntry] {
        let lines = content.components(separatedBy: .newlines)
        
        return lines.compactMap { line in
            return HostEntry.parse(from: line)
        }
    }
    
    /// Returns sample hosts content for development/testing
    private func sampleHostsContent() -> String {
        return """
        ##
        # Host Database
        #
        # localhost is used to configure the loopback interface
        # when the system is booting.  Do not change this entry.
        ##
        127.0.0.1       localhost
        255.255.255.255 broadcasthost
        ::1             localhost
        
        # Development entries
        127.0.0.1       local.dev
        127.0.0.1       api.local.dev
        
        # Blocked sites
        0.0.0.0         ads.example.com
        # 0.0.0.0       tracker.example.com
        
        # Custom entries
        192.168.1.100   my-server.local
        # 10.0.0.50     staging.myapp.com
        """
    }
    
    /// Refreshes the hosts file data
    func refresh() {
        logger.info("Refreshing hosts file data")
        loadHostsFile()
    }
    
    /// Returns the count of enabled entries
    var enabledEntriesCount: Int {
        hostEntries.filter { $0.isEnabled }.count
    }
    
    /// Returns the count of disabled entries
    var disabledEntriesCount: Int {
        hostEntries.filter { !$0.isEnabled }.count
    }
}