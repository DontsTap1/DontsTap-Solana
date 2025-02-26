//
//  Reachibility.swift
//  ARCryptoApp
//
//  Created by Ivan Tkachenko on 25.01.2025.
//

import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")

    enum Status {
        case unreachable
        case wifi
        case cellular
    }

    private(set) var status: Status = .unreachable
    private(set) var isReachable = false

    private var statusUpdateHandlers: [(Status) -> Void] = []

    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            let newReachability = path.status == .satisfied

            var newStatus: Status
            if path.usesInterfaceType(.wifi) {
                newStatus = .wifi
            } else if path.usesInterfaceType(.cellular) {
                newStatus = .cellular
            } else {
                newStatus = .unreachable
            }

            // Only trigger updates if status actually changed
            if newStatus != self.status || newReachability != self.isReachable {
                self.status = newStatus
                self.isReachable = newReachability

                // Notify all registered handlers
                self.statusUpdateHandlers.forEach { handler in
                    handler(newStatus)
                }
            }
        }

        monitor.start(queue: queue)
    }

    func addStatusUpdateHandler(_ handler: @escaping (Status) -> Void) {
        statusUpdateHandlers.append(handler)
    }

    func removeAllStatusUpdateHandlers() {
        statusUpdateHandlers.removeAll()
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    deinit {
        removeAllStatusUpdateHandlers()
        stopMonitoring()
    }
}
