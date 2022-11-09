//
//  AppDelegate.swift
//  TTRx2 AI Edge Scanner
//
//  Created by Amit Yadav on 13/04/20.
//  Copyright © 2020 AQB Solutions Private Limited. All rights reserved.
//

import UIKit
import CoreData
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("App Device ID: \(UIDevice.current.identifierForVendor?.description ?? "")")
        print(UIDevice.current.identifierForVendor?.description ?? "")
        FirebaseApp.configure()
        AFNetworkReachabilityManager.shared().startMonitoring()
        
        let _ = UserInfosModel.UserInfoShared
        let _ = AllProductsModel.AllProductsShared
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            if let rememberedUser = defaults.value(forKey: "rememberedUser") as? Bool {
//                if rememberedUser {
//                    if let _ = defaults.value( forKey: "access_token") as? String , let _ = defaults.value(forKey: "email") as? String , let _ = defaults.value(forKey: "password") as? String {
//                        
//                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//                        let navC = storyboard.instantiateViewController(withIdentifier: "navC") as? UINavigationController
//                        let controller = storyboard.instantiateViewController(withIdentifier: "ThirdView") as! ThirdViewController
//                        navC!.viewControllers = [controller]
//                        appDel.window?.rootViewController = navC
//                        appDel.window?.makeKeyAndVisible()
//                    }
//                }else{
//                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//                    let navC = storyboard.instantiateViewController(withIdentifier: "navC") as? UINavigationController
//                    let controller = storyboard.instantiateViewController(withIdentifier: "ThirdView") as! ThirdViewController
//                    navC!.viewControllers = [controller]
//                    appDel.window?.rootViewController = navC
//                    appDel.window?.makeKeyAndVisible()
//                }
//            }else{
//                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//                let navC = storyboard.instantiateViewController(withIdentifier: "navC") as? UINavigationController
//                let controller = storyboard.instantiateViewController(withIdentifier: "ThirdView") as! ThirdViewController
//                navC!.viewControllers = [controller]
//                appDel.window?.rootViewController = navC
//                appDel.window?.makeKeyAndVisible()
//            }
//        }
        
        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!") //,,,sbm2
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        PersistenceService.saveContext()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        PersistenceService.saveContext()
    }
    
}

