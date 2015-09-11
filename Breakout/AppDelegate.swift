//
//  AppDelegate.swift
//  Breakout
//

import UIKit
import CoreMotion

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    struct Motion {
        static let Manager = CMMotionManager()
    }
}

