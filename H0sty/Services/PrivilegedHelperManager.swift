import Foundation
import ServiceManagement
import Security
import OSLog

/// Manager for installing and communicating with the privileged helper tool
class PrivilegedHelperManager: ObservableObject {
    static let shared = PrivilegedHelperManager()
    
    @Published var isHelperInstalled = false
    @Published var helperVersion: String?
    
    private let logger = Logger(subsystem: "com.h0sty.H0sty", category: "PrivilegedHelperManager")
    private var xpcClient: HostsXPCClient?
    
    private init() {
        checkHelperStatus()
    }
    
    /// Check if the helper tool is installed and get its version
    func checkHelperStatus() {
        Task {
            let installed = await isHelperToolInstalled()
            await MainActor.run {
                self.isHelperInstalled = installed
            }
            
            if installed {
                do {
                    let version = try await getHelperVersion()
                    await MainActor.run {
                        self.helperVersion = version
                    }
                } catch {
                    logger.error("Failed to get helper version: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Install the privileged helper tool using SMJobBless
    func installHelperTool() async throws {
        logger.info("Attempting to install privileged helper tool")
        
        return try await withCheckedThrowingContinuation { continuation in
            var authRef: AuthorizationRef?
            var authItem = AuthorizationItem(
                name: kSMRightBlessPrivilegedHelper,
                valueLength: 0,
                value: nil,
                flags: 0
            )
            
            var authRights = AuthorizationRights(
                count: 1,
                items: &authItem
            )
            
            let authFlags: AuthorizationFlags = [
                .interactionAllowed,
                .preAuthorize,
                .extendRights
            ]
            
            // Request authorization from the user
            let authStatus = AuthorizationCreate(
                &authRights,
                nil,
                authFlags,
                &authRef
            )
            
            guard authStatus == errAuthorizationSuccess else {
                self.logger.error("Authorization failed with status: \(authStatus)")
                continuation.resume(throwing: HostsManagerError.permissionDenied)
                return
            }
            
            // Install the helper tool
            var cfError: Unmanaged<CFError>?
            let blessResult = SMJobBless(
                kSMDomainSystemLaunchd,
                kHostsHelperToolName as CFString,
                authRef,
                &cfError
            )
            
            // Clean up authorization
            if let authRef = authRef {
                AuthorizationFree(authRef, [])
            }
            
            if blessResult {
                self.logger.info("Helper tool installed successfully")
                self.isHelperInstalled = true
                self.xpcClient = HostsXPCClient()
                continuation.resume()
            } else {
                let error = cfError?.takeRetainedValue() as Error?
                self.logger.error("Failed to install helper tool: \(error?.localizedDescription ?? "Unknown error")")
                continuation.resume(throwing: HostsManagerError.helperToolNotInstalled)
            }
        }
    }
    
    /// Check if the helper tool is installed
    private func isHelperToolInstalled() async -> Bool {
        // Try to connect to the helper tool via XPC
        do {
            if xpcClient == nil {
                xpcClient = HostsXPCClient()
            }
            _ = try await xpcClient?.getVersion()
            return true
        } catch {
            logger.info("Helper tool not installed or not responding: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Get the version of the installed helper tool
    private func getHelperVersion() async throws -> String {
        if xpcClient == nil {
            xpcClient = HostsXPCClient()
        }
        
        guard let client = xpcClient else {
            throw HostsManagerError.helperToolNotInstalled
        }
        
        return try await client.getVersion()
    }
    
    /// Get the XPC client for communicating with the helper tool
    func getXPCClient() throws -> HostsXPCClient {
        guard isHelperInstalled else {
            throw HostsManagerError.helperToolNotInstalled
        }
        
        if xpcClient == nil {
            xpcClient = HostsXPCClient()
        }
        
        guard let client = xpcClient else {
            throw HostsManagerError.operationFailed("Failed to create XPC client")
        }
        
        return client
    }
}