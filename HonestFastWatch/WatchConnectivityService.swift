import Foundation
import WatchConnectivity

/// Watch-side WatchConnectivity for syncing fasting state with iPhone
final class WatchConnectivityService: NSObject, ObservableObject {
    static let shared = WatchConnectivityService()
    
    @Published var isPhoneReachable = false
    
    /// Called when phone sends a state update
    var onStateReceived: (([String: Any]) -> Void)?
    
    private let suiteName = "group.com.loopspur.honestfast"
    
    private override init() {
        super.init()
    }
    
    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    /// Push fasting state from watch to phone
    func sendStateToPhone(isFasting: Bool, startTime: Double, targetHours: Double, planName: String) {
        guard WCSession.default.activationState == .activated else { return }
        
        let context: [String: Any] = [
            "isFasting": isFasting,
            "fastStartTime": startTime,
            "fastDurationHours": targetHours,
            "planName": planName,
            "lastSyncTimestamp": Date().timeIntervalSince1970
        ]
        
        try? WCSession.default.updateApplicationContext(context)
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(context, replyHandler: nil)
        }
    }
    
    /// Read shared state (watch uses UserDefaults directly since App Group works on watchOS too)
    private var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }
    
    func applyState(_ dict: [String: Any]) {
        let defaults = self.defaults
        if let v = dict["isFasting"] as? Bool { defaults.set(v, forKey: "isFasting") }
        if let v = dict["fastStartTime"] as? Double { defaults.set(v, forKey: "fastStartTime") }
        if let v = dict["fastDurationHours"] as? Double { defaults.set(v, forKey: "fastDurationHours") }
        if let v = dict["planName"] as? String { defaults.set(v, forKey: "planName") }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityService: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPhoneReachable = session.isReachable
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            self.applyState(message)
            self.onStateReceived?(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            self.applyState(applicationContext)
            self.onStateReceived?(applicationContext)
        }
    }
}
