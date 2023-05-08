//
//  AppDelegate.swift
//  Breakout
//
//  Created by Out East on 22.07.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var startTime: Date?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let barTintColor = #colorLiteral(red: 0.08235294118, green: 0.1137254902, blue: 0.2392156863, alpha: 0.5)
        
        UITabBar.appearance().barTintColor = barTintColor
        UITabBar.appearance(for: .current).barTintColor = barTintColor
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        guard let startTime = self.startTime else {
            return
        }
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        print(duration)
        UserProgress.timeSpent += duration
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//        print("something")
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.startTime = Date()
    }
}

