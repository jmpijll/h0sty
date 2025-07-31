import Foundation
import OSLog

/// Main entry point for the privileged helper tool
@main
struct HostsHelper {
    static func main() {
        let logger = Logger(subsystem: "com.h0sty.H0sty.HostsHelper", category: "Main")
        logger.info("Starting HostsHelper version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown")")
        
        // Set up the XPC listener
        let listener = NSXPCListener.service()
        let delegate = HostsHelperXPCService()
        listener.delegate = delegate
        
        // Start listening for connections
        listener.resume()
        logger.info("HostsHelper is ready to accept connections")
        
        // Keep the helper tool running
        RunLoop.current.run()
    }
}