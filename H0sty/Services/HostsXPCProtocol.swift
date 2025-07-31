import Foundation
import OSLog

/// XPC service name - must match the helper tool's bundle identifier
let kHostsHelperToolName = "com.h0sty.H0sty.HostsHelper"

/// XPC protocol for communication between the main app and privileged helper tool
@objc protocol HostsXPCProtocol {
    
    /// Get the current version of the helper tool
    func getVersion(reply: @escaping (String) -> Void)
    
    /// Read the hosts file and return its contents
    func readHostsFile(reply: @escaping (Result<String, HostsHelperError>) -> Void)
    
    /// Write the hosts file with new contents
    func writeHostsFile(_ contents: String, reply: @escaping (Result<Void, HostsHelperError>) -> Void)
    
    /// Add a new host entry to the hosts file
    func addHostEntry(_ entry: HostsEntryData, reply: @escaping (Result<Void, HostsHelperError>) -> Void)
    
    /// Remove a host entry from the hosts file
    func removeHostEntry(ip: String, hostname: String, reply: @escaping (Result<Void, HostsHelperError>) -> Void)
    
    /// Toggle a host entry (enable/disable by commenting/uncommenting)
    func toggleHostEntry(ip: String, hostname: String, reply: @escaping (Result<Void, HostsHelperError>) -> Void)
}

/// Data structure for host entries that can be sent over XPC
struct HostsEntryData: Codable {
    let ip: String
    let hostname: String
    let comment: String?
    let isEnabled: Bool
    
    init(from hostEntry: HostEntry) {
        self.ip = hostEntry.ip
        self.hostname = hostEntry.hostname
        self.comment = hostEntry.comment
        self.isEnabled = hostEntry.isEnabled
    }
    
    func toHostEntry() -> HostEntry {
        return HostEntry(ip: ip, hostname: hostname, comment: comment, isEnabled: isEnabled)
    }
}

/// Errors that can occur in the helper tool
enum HostsHelperError: Int, Error, LocalizedError, Codable {
    case fileNotFound = 1
    case permissionDenied = 2
    case invalidData = 3
    case operationFailed = 4
    case invalidEntry = 5
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Hosts file not found"
        case .permissionDenied:
            return "Permission denied to modify hosts file"
        case .invalidData:
            return "Invalid data provided"
        case .operationFailed:
            return "Operation failed"
        case .invalidEntry:
            return "Invalid host entry format"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return "Ensure the hosts file exists at /etc/hosts"
        case .permissionDenied:
            return "Restart the application and try again"
        case .invalidData, .invalidEntry:
            return "Check the IP address and hostname format"
        case .operationFailed:
            return "Please try the operation again"
        }
    }
}

/// XPC client for communicating with the privileged helper tool
class HostsXPCClient {
    private var connection: NSXPCConnection?
    private let logger = Logger(subsystem: "com.h0sty.H0sty", category: "XPCClient")
    
    init() {
        setupConnection()
    }
    
    deinit {
        connection?.invalidate()
    }
    
    private func setupConnection() {
        connection = NSXPCConnection(machServiceName: kHostsHelperToolName, options: .privileged)
        connection?.remoteObjectInterface = NSXPCInterface(with: HostsXPCProtocol.self)
        
        connection?.invalidationHandler = {
            self.logger.warning("XPC connection invalidated")
            self.connection = nil
        }
        
        connection?.interruptionHandler = {
            self.logger.warning("XPC connection interrupted")
        }
        
        connection?.resume()
        logger.info("XPC connection established to \(kHostsHelperToolName)")
    }
    
    private func getRemoteProxy() -> HostsXPCProtocol? {
        guard let connection = connection else {
            logger.error("No XPC connection available")
            return nil
        }
        
        return connection.remoteObjectProxy as? HostsXPCProtocol
    }
    
    /// Get the version of the helper tool
    func getVersion() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            guard let proxy = getRemoteProxy() else {
                continuation.resume(throwing: HostsHelperError.operationFailed)
                return
            }
            
            proxy.getVersion { version in
                continuation.resume(returning: version)
            }
        }
    }
    
    /// Read the hosts file contents
    func readHostsFile() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            guard let proxy = getRemoteProxy() else {
                continuation.resume(throwing: HostsHelperError.operationFailed)
                return
            }
            
            proxy.readHostsFile { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Write new contents to the hosts file
    func writeHostsFile(_ contents: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            guard let proxy = getRemoteProxy() else {
                continuation.resume(throwing: HostsHelperError.operationFailed)
                return
            }
            
            proxy.writeHostsFile(contents) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Add a new host entry
    func addHostEntry(_ entry: HostEntry) async throws {
        let entryData = HostsEntryData(from: entry)
        
        return try await withCheckedThrowingContinuation { continuation in
            guard let proxy = getRemoteProxy() else {
                continuation.resume(throwing: HostsHelperError.operationFailed)
                return
            }
            
            proxy.addHostEntry(entryData) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Remove a host entry
    func removeHostEntry(ip: String, hostname: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            guard let proxy = getRemoteProxy() else {
                continuation.resume(throwing: HostsHelperError.operationFailed)
                return
            }
            
            proxy.removeHostEntry(ip: ip, hostname: hostname) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Toggle (enable/disable) a host entry
    func toggleHostEntry(ip: String, hostname: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            guard let proxy = getRemoteProxy() else {
                continuation.resume(throwing: HostsHelperError.operationFailed)
                return
            }
            
            proxy.toggleHostEntry(ip: ip, hostname: hostname) { result in
                continuation.resume(with: result)
            }
        }
    }
}