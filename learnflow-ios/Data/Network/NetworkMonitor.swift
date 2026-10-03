import Foundation
import Network
import Combine

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    @Published private(set) var isConnected: Bool = true
    @Published var isSimulatedOffline: Bool = false {
        didSet {
            updateEffectiveConnection()
        }
    }
    
    @Published private(set) var isEffectiveConnected: Bool = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.updateEffectiveConnection()
            }
        }
        monitor.start(queue: queue)
    }
    
    private func updateEffectiveConnection() {
        isEffectiveConnected = isConnected && !isSimulatedOffline
    }
}
