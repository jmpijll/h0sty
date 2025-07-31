import Foundation
import OSLog

/// Errors that can occur during hosts file operations
enum HostsManagerError: LocalizedError {
    case fileNotFound
    case permissionDenied
    case invalidEntry
    case helperToolNotInstalled
    case operationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Hosts file not found"
        case .permissionDenied:
            return "Permission denied"
        case .invalidEntry:
            return "Invalid host entry"
        case .helperToolNotInstalled:
            return "Privileged helper tool not installed"
        case .operationFailed(let message):
            return "Operation failed: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "Please ensure H0sty has the necessary permissions."
        case .helperToolNotInstalled:
            return "The app will install the helper tool when you perform your first edit."
        case .invalidEntry:
            return "Please check the IP address and hostname format."
        default:
            return "Please try again or restart the application."
        }
    }
}

/// Service responsible for reading and managing the hosts file
@MainActor
class HostsManager: ObservableObject {
    @Published var hostEntries: [HostEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastError: HostsManagerError?
    
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
    
    // MARK: - Editing Operations (Phase 2)
    // These methods use the privileged helper tool for actual file modification
    
    /// Add a new host entry
    func addEntry(_ entry: HostEntry) async throws {
        logger.info("Adding entry: \(entry.hostname) -> \(entry.ip)")
        
        // Validate entry
        guard !entry.ip.isEmpty && !entry.hostname.isEmpty else {
            throw HostsManagerError.invalidEntry
        }
        
        // Check for duplicates
        if hostEntries.contains(where: { $0.hostname == entry.hostname && $0.ip == entry.ip }) {
            throw HostsManagerError.operationFailed("Entry already exists")
        }
        
        isLoading = true
        lastError = nil
        
        do {
            // Ensure helper tool is installed
            let helperManager = PrivilegedHelperManager.shared
            if !helperManager.isHelperInstalled {
                try await helperManager.installHelperTool()
            }
            
            // Use XPC to add the entry
            let xpcClient = try helperManager.getXPCClient()
            try await xpcClient.addHostEntry(entry)
            
            // Refresh the hosts file to update local state
            await loadHostsFile()
            
            logger.info("Successfully added entry: \(entry.hostname)")
            
        } catch let helperError as HostsHelperError {
            let hostsError = HostsManagerError.operationFailed(helperError.localizedDescription)
            lastError = hostsError
            throw hostsError
        } catch {
            let hostsError = HostsManagerError.operationFailed(error.localizedDescription)
            lastError = hostsError
            throw hostsError
        }
        
        isLoading = false
    }
    
    /// Delete a host entry
    func deleteEntry(_ entry: HostEntry) async throws {
        logger.info("Deleting entry: \(entry.hostname) -> \(entry.ip)")
        
        isLoading = true
        lastError = nil
        
        do {
            // Ensure helper tool is installed
            let helperManager = PrivilegedHelperManager.shared
            if !helperManager.isHelperInstalled {
                try await helperManager.installHelperTool()
            }
            
            // Use XPC to remove the entry
            let xpcClient = try helperManager.getXPCClient()
            try await xpcClient.removeHostEntry(ip: entry.ip, hostname: entry.hostname)
            
            // Refresh the hosts file to update local state
            await loadHostsFile()
            
            logger.info("Successfully deleted entry: \(entry.hostname)")
            
        } catch let helperError as HostsHelperError {
            let hostsError = HostsManagerError.operationFailed(helperError.localizedDescription)
            lastError = hostsError
            throw hostsError
        } catch {
            let hostsError = HostsManagerError.operationFailed(error.localizedDescription)
            lastError = hostsError
            throw hostsError
        }
        
        isLoading = false
    }
    
    /// Toggle a host entry (enable/disable)
    func toggleEntry(_ entry: HostEntry) async throws {
        logger.info("Toggling entry: \(entry.hostname) -> \(entry.ip) (currently \(entry.isEnabled ? "enabled" : "disabled"))")
        
        isLoading = true
        lastError = nil
        
        do {
            // Ensure helper tool is installed
            let helperManager = PrivilegedHelperManager.shared
            if !helperManager.isHelperInstalled {
                try await helperManager.installHelperTool()
            }
            
            // Use XPC to toggle the entry
            let xpcClient = try helperManager.getXPCClient()
            try await xpcClient.toggleHostEntry(ip: entry.ip, hostname: entry.hostname)
            
            // Refresh the hosts file to update local state
            await loadHostsFile()
            
            logger.info("Successfully toggled entry: \(entry.hostname)")
            
        } catch let helperError as HostsHelperError {
            let hostsError = HostsManagerError.operationFailed(helperError.localizedDescription)
            lastError = hostsError
            throw hostsError
        } catch {
            let hostsError = HostsManagerError.operationFailed(error.localizedDescription)
            lastError = hostsError
            throw hostsError
        }
        
        isLoading = false
    }
}