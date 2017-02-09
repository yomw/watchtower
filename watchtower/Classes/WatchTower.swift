import Foundation
import CoreLocation
import CoreBluetooth

public protocol WatchTowerManager {
    func watchTower(_ watchTower: WatchTower!, didFind beacons: [CLBeacon])
    func watchTower(_ watchTower: WatchTower!, didLose beacons: [CLBeacon])
    func watchTower(_ watchTower: WatchTower!, didEnter region: CLRegion)
    func watchTower(_ watchTower: WatchTower!, didExit region: CLRegion)
    func watchTower(_ watchTower: WatchTower!, beacon: CLBeacon!, didUpdateProximity from: CLProximity, to: CLProximity)
}

public extension WatchTowerManager {
    func watchTower(_ watchTower: WatchTower!, didFind beacons: [CLBeacon]) {}
    func watchTower(_ watchTower: WatchTower!, didLose beacons: [CLBeacon]) {}
    func watchTower(_ watchTower: WatchTower!, didEnter region: CLRegion) {}
    func watchTower(_ watchTower: WatchTower!, didExit region: CLRegion) {}
    func watchTower(_ watchTower: WatchTower!, beacon: CLBeacon!, didUpdateProximity from: CLProximity, to: CLProximity) {}

}

open class WatchTower: NSObject {
    fileprivate var locationManager: CLLocationManager
    fileprivate var btManager: CBPeripheralManager
    fileprivate var regions: [String: CLBeaconRegion]
    private var interval: TimeInterval = 0
    fileprivate var detectedBeacons: [String: CLBeacon]

    open static let shared = WatchTower()

    open var manager: WatchTowerManager?

    override init() {
        locationManager = CLLocationManager()
        btManager = CBPeripheralManager()
        regions = [String: CLBeaconRegion]()
        detectedBeacons = [String: CLBeacon]()
        super.init()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        btManager.delegate = self
    }

    open func listenToBeacons(uuids: [UUID]) {
        for uuid in uuids {
            let region = CLBeaconRegion(proximityUUID: uuid, identifier: "com.wopata.watchtower-\(uuid)")
            regions[uuid.uuidString] = region
        }
    }

    open func listenToBeacons(_ uuids: [UUID], at timeInterval: TimeInterval) {
        interval = timeInterval
        listenToBeacons(uuids: uuids)
    }

    open func stopListening() {
        for (uuid, region) in regions {
            locationManager.stopRangingBeacons(in: region)
            locationManager.stopMonitoring(for: region)
            regions[uuid] = nil
        }
    }

    open func stopListening(uuid: String) {
        if let region = regions[uuid] {
            locationManager.stopRangingBeacons(in: region)
            locationManager.stopMonitoring(for: region)
            regions[uuid] = nil
        }
    }
}

extension WatchTower {
    fileprivate func startBeacons() {
        for (_, region) in regions {
            region.notifyEntryStateOnDisplay = true
            locationManager.startMonitoring(for: region)
            locationManager.startRangingBeacons(in: region)
            locationManager.requestState(for: region)
        }
    }
}

extension WatchTower: CBPeripheralManagerDelegate {
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
        }
    }
}

extension WatchTower: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined && status != .denied {
            startBeacons()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    public func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print(error)
    }

    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }

    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        var lostBeacons = detectedBeacons
        var foundBeacons = [String: CLBeacon]()
        var proximityUpdates = [(beacon: CLBeacon, oldProximity: CLProximity)]()
        for beacon in beacons {
            let identifier = beacon.identifier
            if let oldBeacon = detectedBeacons[identifier] {
                _ = lostBeacons.removeValue(forKey: identifier)
                if oldBeacon.proximity != beacon.proximity {
                    proximityUpdates.append((beacon: beacon, oldProximity: oldBeacon.proximity))
                }
            } else {
                foundBeacons[identifier] = beacon
                proximityUpdates.append((beacon: beacon, oldProximity: .unknown))
            }
            detectedBeacons[identifier] = beacon
        }

        for (identifier, _) in lostBeacons {
            detectedBeacons.removeValue(forKey: identifier)
        }

        let lost: [CLBeacon] = Array(lostBeacons.values)
        if !lost.isEmpty {
            self.manager?.watchTower(self, didLose: lost)
        }

        let found: [CLBeacon] = Array(foundBeacons.values)
        if !found.isEmpty {
            self.manager?.watchTower(self, didFind: found)
        }

        for update in proximityUpdates {
            self.manager?.watchTower(self, beacon: update.beacon, didUpdateProximity: update.oldProximity, to: update.beacon.proximity)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.manager?.watchTower(self, didEnter: region)
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.manager?.watchTower(self, didExit: region)
    }
}

public extension CLBeacon {
    var identifier: String {
        return "WatchTower:\(proximityUUID.uuidString):\(major):\(minor)"
    }
}
