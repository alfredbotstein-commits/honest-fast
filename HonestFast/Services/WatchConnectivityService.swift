import Foundation
import WatchConnectivity
import Combine

/// iPhone-side WatchConnectivity for syncing fasting state with Apple Watch
final class WatchConnectivityService: NSObject, ObservableObject {
    static let shared = WatchConnectivityService()
    
    @Published var isWatchReachable = false
    
    /// Called when watch sends a state update (start/end fast from watch)
    var onStateReceived: (([String: Any]) -> Void)?
    
    private override init() {
        super.init()
    }
    
    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    /// Push current fasting state to watch
    func sendStateToWatch() {
        guard WCSession.default.activationState == .activated else { return }
        
        let context = SharedDefaults.currentStateDict()
        
        // Use application context (guaranteed delivery, latest-wins)
        try? WCSession.default.updateApplicationContext(context)
        
        // Also send message for immediate delivery if reachable
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(context, replyHandler: nil)
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityService: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
        }
        // Send current state on activation
        if activationState == .activated {
            sendStateToWatch()
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate for switching watches
        session.activate()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
        }
    }
    
    // Receive immediate messages from watch
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            SharedDefaults.apply(dict: message)
            self.onStateReceived?(message)
        }
    }
    
    // Receive application context updates from watch
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            SharedDefaults.apply(dict: applicationContext)
            self.onStateReceived?(applicationContext)
        }
    }
}
