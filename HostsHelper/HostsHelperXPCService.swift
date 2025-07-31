import Foundation
import OSLog

/// XPC service implementation for the privileged helper tool
class HostsHelperXPCService: NSObject, NSXPCListenerDelegate, HostsXPCProtocol {
    private let logger = Logger(subsystem: "com.h0sty.H0sty.HostsHelper", category: "XPCService")
    private let hostsFilePath = "/etc/hosts"
    
    // MARK: - NSXPCListenerDelegate
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        logger.info("New XPC connection requested from PID: \(newConnection.processIdentifier)")
        
        // Set up the connection
        newConnection.exportedInterface = NSXPCInterface(with: HostsXPCProtocol.self)
        newConnection.exportedObject = self
        
        newConnection.invalidationHandler = {
            self.logger.info("XPC connection invalidated")
        }
        
        newConnection.interruptionHandler = {
            self.logger.info("XPC connection interrupted")
        }
        
        // TODO: Add code signing verification here for security
        // For now, we'll accept all connections (development only)
        
        newConnection.resume()
        logger.info("XPC connection accepted and resumed")
        
        return true
    }
    
    // MARK: - HostsXPCProtocol Implementation
    
    func getVersion(reply: @escaping (String) -> Void) {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1.0.0"
        logger.info("Version requested: \(version)")
        reply(version)
    }
    
    func readHostsFile(reply: @escaping (Result<String, HostsHelperError>) -> Void) {
        logger.info("Reading hosts file: \(hostsFilePath)")
        
        do {
            let contents = try String(contentsOfFile: hostsFilePath, encoding: .utf8)
            logger.info("Successfully read hosts file (\(contents.count) characters)")
            reply(.success(contents))
        } catch {
            logger.error("Failed to read hosts file: \(error.localizedDescription)")
            reply(.failure(.fileNotFound))
        }
    }
    
    func writeHostsFile(_ contents: String, reply: @escaping (Result<Void, HostsHelperError>) -> Void) {
        logger.info("Writing hosts file with \(contents.count) characters")
        
        do {
            // Create a backup first
            let backupPath = hostsFilePath + ".backup"
            if FileManager.default.fileExists(atPath: hostsFilePath) {
                try FileManager.default.copyItem(atPath: hostsFilePath, toPath: backupPath)
                logger.info("Created backup at \(backupPath)")
            }
            
            // Write the new contents
            try contents.write(toFile: hostsFilePath, atomically: true, encoding: .utf8)
            
            // Set proper permissions (readable by all, writable by root)
            let attributes = [FileAttributeKey.posixPermissions: 0o644]
            try FileManager.default.setAttributes(attributes, ofItemAtPath: hostsFilePath)
            
            logger.info("Successfully wrote hosts file")
            reply(.success(()))
            
        } catch {
            logger.error("Failed to write hosts file: \(error.localizedDescription)")
            reply(.failure(.permissionDenied))
        }
    }
    
    func addHostEntry(_ entry: HostsEntryData, reply: @escaping (Result<Void, HostsHelperError>) -> Void) {
        logger.info("Adding host entry: \(entry.ip) \(entry.hostname)")
        
        guard isValidIPAddress(entry.ip) && isValidHostname(entry.hostname) else {
            logger.error("Invalid host entry format")
            reply(.failure(.invalidEntry))
            return
        }
        
        do {
            // Read current contents
            let currentContents = try String(contentsOfFile: hostsFilePath, encoding: .utf8)
            var lines = currentContents.components(separatedBy: .newlines)
            
            // Check if entry already exists
            for line in lines {
                let parts = parseHostsLine(line)
                if parts.ip == entry.ip && parts.hostname == entry.hostname {
                    logger.warning("Host entry already exists")
                    reply(.failure(.operationFailed))
                    return
                }
            }
            
            // Create new entry line
            let prefix = entry.isEnabled ? "" : "# "
            let comment = entry.comment?.isEmpty == false ? " # \(entry.comment!)" : ""
            let newLine = "\(prefix)\(entry.ip)\t\(entry.hostname)\(comment)"
            
            // Add the new line
            lines.append(newLine)
            
            // Write back to file
            let newContents = lines.joined(separator: "\n")
            try newContents.write(toFile: hostsFilePath, atomically: true, encoding: .utf8)
            
            logger.info("Successfully added host entry")
            reply(.success(()))
            
        } catch {
            logger.error("Failed to add host entry: \(error.localizedDescription)")
            reply(.failure(.operationFailed))
        }
    }
    
    func removeHostEntry(ip: String, hostname: String, reply: @escaping (Result<Void, HostsHelperError>) -> Void) {
        logger.info("Removing host entry: \(ip) \(hostname)")
        
        do {
            // Read current contents
            let currentContents = try String(contentsOfFile: hostsFilePath, encoding: .utf8)
            var lines = currentContents.components(separatedBy: .newlines)
            
            // Find and remove the matching entry
            var found = false
            lines = lines.filter { line in
                let parts = parseHostsLine(line)
                if parts.ip == ip && parts.hostname == hostname {
                    found = true
                    return false // Remove this line
                }
                return true // Keep this line
            }
            
            guard found else {
                logger.warning("Host entry not found for removal")
                reply(.failure(.operationFailed))
                return
            }
            
            // Write back to file
            let newContents = lines.joined(separator: "\n")
            try newContents.write(toFile: hostsFilePath, atomically: true, encoding: .utf8)
            
            logger.info("Successfully removed host entry")
            reply(.success(()))
            
        } catch {
            logger.error("Failed to remove host entry: \(error.localizedDescription)")
            reply(.failure(.operationFailed))
        }
    }
    
    func toggleHostEntry(ip: String, hostname: String, reply: @escaping (Result<Void, HostsHelperError>) -> Void) {
        logger.info("Toggling host entry: \(ip) \(hostname)")
        
        do {
            // Read current contents
            let currentContents = try String(contentsOfFile: hostsFilePath, encoding: .utf8)
            let lines = currentContents.components(separatedBy: .newlines)
            
            // Find and toggle the matching entry
            var found = false
            let modifiedLines = lines.map { line in
                let parts = parseHostsLine(line)
                if parts.ip == ip && parts.hostname == hostname {
                    found = true
                    // Toggle the comment status
                    if line.trimmingCharacters(in: .whitespaces).hasPrefix("#") {
                        // Currently disabled, enable it
                        return line.replacingOccurrences(of: "^\\s*#\\s*", with: "", options: .regularExpression)
                    } else {
                        // Currently enabled, disable it
                        return "# \(line)"
                    }
                }
                return line
            }
            
            guard found else {
                logger.warning("Host entry not found for toggle")
                reply(.failure(.operationFailed))
                return
            }
            
            // Write back to file
            let newContents = modifiedLines.joined(separator: "\n")
            try newContents.write(toFile: hostsFilePath, atomically: true, encoding: .utf8)
            
            logger.info("Successfully toggled host entry")
            reply(.success(()))
            
        } catch {
            logger.error("Failed to toggle host entry: \(error.localizedDescription)")
            reply(.failure(.operationFailed))
        }
    }
    
    // MARK: - Helper Methods
    
    private func parseHostsLine(_ line: String) -> (ip: String, hostname: String, comment: String?, isEnabled: Bool) {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        let isEnabled = !trimmedLine.hasPrefix("#")
        
        // Remove comment prefix if present
        let workingLine = isEnabled ? trimmedLine : String(trimmedLine.dropFirst().trimmingCharacters(in: .whitespaces))
        
        // Split by whitespace and comments
        let parts = workingLine.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        guard parts.count >= 2 else {
            return (ip: "", hostname: "", comment: nil, isEnabled: isEnabled)
        }
        
        let ip = parts[0]
        let hostname = parts[1]
        
        // Extract comment if present
        var comment: String?
        if let commentIndex = workingLine.firstIndex(of: "#") {
            let commentPart = String(workingLine[commentIndex...]).dropFirst().trimmingCharacters(in: .whitespaces)
            comment = commentPart.isEmpty ? nil : commentPart
        }
        
        return (ip: ip, hostname: hostname, comment: comment, isEnabled: isEnabled)
    }
    
    private func isValidIPAddress(_ ip: String) -> Bool {
        // Basic IPv4 validation
        let ipv4Pattern = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
        let ipv4Regex = try? NSRegularExpression(pattern: ipv4Pattern)
        let ipv4Range = NSRange(location: 0, length: ip.utf16.count)
        
        if ipv4Regex?.firstMatch(in: ip, options: [], range: ipv4Range) != nil {
            return true
        }
        
        // Basic IPv6 validation (simplified)
        let ipv6Pattern = "^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$|^::1$|^::$"
        let ipv6Regex = try? NSRegularExpression(pattern: ipv6Pattern)
        let ipv6Range = NSRange(location: 0, length: ip.utf16.count)
        
        if ipv6Regex?.firstMatch(in: ip, options: [], range: ipv6Range) != nil {
            return true
        }
        
        // Allow common special cases
        return ["0.0.0.0", "localhost"].contains(ip)
    }
    
    private func isValidHostname(_ hostname: String) -> Bool {
        // Basic hostname validation
        let hostnamePattern = "^[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?(\\.([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?))*$"
        let regex = try? NSRegularExpression(pattern: hostnamePattern)
        let range = NSRange(location: 0, length: hostname.utf16.count)
        
        return regex?.firstMatch(in: hostname, options: [], range: range) != nil
    }
}