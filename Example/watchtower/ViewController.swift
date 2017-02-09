//
//  ViewController.swift
//  watchtower
//
//  Created by Guillaume Bellue on 02/08/2017.
//  Copyright (c) 2017 Guillaume Bellue. All rights reserved.
//

import UIKit
import WatchTower
import CoreLocation

class ViewController: UIViewController, WatchTowerManager {
    @IBOutlet private weak var loading: UIView!
    @IBOutlet private weak var log: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loading.isHidden = false
        log.isHidden = true

        WatchTower.shared.manager = self
        WatchTower.shared.listenToBeacons(uuids: [UUID(uuidString: "b9407f30-f5f8-466e-aff9-25556b57fe6d")!])
    }

    private func showLog(_ text: String) {
        loading.isHidden = true
        log.isHidden = false

        let existing = log.text ?? ""
        log.text = "• \(text)\n\n\(existing)"
    }

    func watchTower(_ watchTower: WatchTower!, didEnter region: CLRegion) {
        showLog("didEnterRegion: \(region)")
    }

    func watchTower(_ watchTower: WatchTower!, didExit region: CLRegion) {
        showLog("didExitRegion: \(region)")
    }

    func watchTower(_ watchTower: WatchTower!, didFind beacons: [CLBeacon]) {
        showLog("didFindBeacons: \(beacons.map { $0.identifier })")
    }

    func watchTower(_ watchTower: WatchTower!, didLose beacons: [CLBeacon]) {
        showLog("didLoseBeacons: \(beacons.map { $0.identifier })")
    }

    func watchTower(_ watchTower: WatchTower!, beacon: CLBeacon!, didUpdateProximity from: CLProximity, to: CLProximity) {
        showLog("beacon \(beacon.identifier) didUpdateProximity from \(from.rawValue) to \(to.rawValue)")
    }
}

