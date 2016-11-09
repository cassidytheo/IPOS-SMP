//
//  AppDelegate.swift
//  Simaspay
//
//  Created by Kendy Susantho on 9/21/16.
//  Copyright © 2016 Kendy Susantho. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var navigation: UINavigationController!
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.backToRoot), name: NSNotification.Name(rawValue: "forceLogout"), object: nil)
        
        // Override point for customization after application launch.
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        window = UIWindow(frame: UIScreen.main.bounds);
        
        let view = SplashScreenViewController.initWithOwnNib()
        let navController = UINavigationController(rootViewController: view)
        navController.navigationBar.isHidden = true;
        window!.rootViewController = navController;
        window!.makeKeyAndVisible()
        self.navigation = navController
        return true
    }
    
    func backToRoot() {
        let viewControllers: [UIViewController] = self.navigation!.viewControllers as [UIViewController];
        for vc in viewControllers {
            if (vc.isKind(of: LoginRegisterViewController.self)) {
                self.navigation!.popToViewController(vc, animated: true);
                return
            }
        }
        
        self.navigation!.popToRootViewController(animated: true)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

