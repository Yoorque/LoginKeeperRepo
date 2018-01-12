//
//  AppDelegate.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADBannerViewDelegate {

    var window: UIWindow?
    var adBannerView: GADBannerView!
    var accountsVC: AccountsViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("didFinishLaunchingWithOptions")
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9468673959133010~5601234686")
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView!.delegate = self
        adBannerView!.adUnitID = "ca-app-pub-9468673959133010/5461633889"
        
        UINavigationBar.appearance().tintColor = UIColor(red: 56/255, green: 124/255, blue: 254/255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 56/255, green: 124/255, blue: 254/255, alpha: 1), NSAttributedStringKey.font: UIFont(name: "Zapf Dingbats", size: 15)!]
        
        return true
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidLoadAd")
        
        bannerView.isHidden = false
        let transform = CGAffineTransform(translationX: 0, y: adBannerView!.bounds.size.height)
        bannerView.transform = transform
        
        UIView.animate(withDuration: 0.5, animations: {
            self.adBannerView!.transform = CGAffineTransform.identity
        })
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
        bannerView.isHidden = true
    }
    
    func loadAd(forViewController controller: UIViewController) {
        load(bannerView: adBannerView,forViewController: controller, andOrientation: UIDevice.current.orientation)
    }
    
    func load(bannerView: GADBannerView ,forViewController viewController: UIViewController, andOrientation orientation: UIDeviceOrientation) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(adBannerView!)
        switch orientation {
        case .portrait:
             adBannerView!.adSize = kGADAdSizeSmartBannerPortrait
        case .landscapeLeft, .landscapeRight:
            adBannerView!.adSize = kGADAdSizeSmartBannerLandscape
        case .faceUp:
            adBannerView!.adSize = kGADAdSizeSmartBannerPortrait
        default:
            adBannerView!.adSize = kGADAdSizeSmartBannerPortrait
        }
        
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            let guide = viewController.view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
                guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
                guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
                ])
        }
        else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            viewController.view.addConstraint(NSLayoutConstraint(item: bannerView,
                                                  attribute: .leading,
                                                  relatedBy: .equal,
                                                  toItem: viewController.view,
                                                  attribute: .leading,
                                                  multiplier: 1,
                                                  constant: 0))
            viewController.view.addConstraint(NSLayoutConstraint(item: bannerView,
                                                  attribute: .trailing,
                                                  relatedBy: .equal,
                                                  toItem: viewController.view,
                                                  attribute: .trailing,
                                                  multiplier: 1,
                                                  constant: 0))
            viewController.view.addConstraint(NSLayoutConstraint(item: bannerView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: viewController.bottomLayoutGuide,
                                                  attribute: .top,
                                                  multiplier: 1,
                                                  constant: 0))
        }
        
        adBannerView!.rootViewController = viewController
        adBannerView!.load(GADRequest())
        
        adBannerView!.isHidden = true
    }
    
    func removeBannerView() {
        adBannerView!.removeFromSuperview()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        removeBannerView()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "LoginKeeper")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

