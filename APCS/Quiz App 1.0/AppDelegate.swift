//
//  AppDelegate.swift
//  Quiz App Starter Kit All In One 1.0
//
//

import UIKit
import StoreKit
import GoogleMobileAds
import SwiftyStoreKit

extension UINavigationBar {
    func transparentNavigationBar() {
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        HASettings.sharedInstance.setAdsTurnedOff(show: false)
        //only for testing remove while uploading
        //resetPurchases()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ (kGADSimulatorID as! String) ]
        HAQuizDataManager.sharedInstance.disableAdsIfBougtInAppPurchase()
        
        window = UIWindow.init()
        window?.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
        let controller = HAMainViewController.init(nibName: "HAMainViewController", bundle: nil)
        navigationController = UINavigationController.init(rootViewController: controller)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
        
        let navStyles = UINavigationBar.appearance()
        // This will set the color of the text for the back buttons.
        navStyles.shadowImage = UIImage()
        navStyles.tintColor = UIColor(hexString: HASettings.sharedInstance.appTextColor)
        navStyles.backgroundColor = .clear
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: UIControl.State.highlighted)
         setupIAP()
        
        
        return true
    }
    
    //TODO: only for testing
    func resetPurchases() {
        let storage:NSUbiquitousKeyValueStore  = NSUbiquitousKeyValueStore.default
        storage.removeObject(forKey: practice1ExpirationDateKey)
        storage.removeObject(forKey: practice2ExpirationDateKey)
        storage.removeObject(forKey: practice3ExpirationDateKey)
        storage.removeObject(forKey: practice4ExpirationDateKey)
        storage.removeObject(forKey: practice5ExpirationDateKey)
        storage.removeObject(forKey: practiceBundleExpirationDateKey)
        storage.synchronize()
        
        let localStorage:UserDefaults = UserDefaults.standard;
        localStorage.removeObject(forKey: practice1ExpirationDateKey)
        localStorage.removeObject(forKey: practice2ExpirationDateKey)
        localStorage.removeObject(forKey: practice3ExpirationDateKey)
        localStorage.removeObject(forKey: practice4ExpirationDateKey)
        localStorage.removeObject(forKey: practice5ExpirationDateKey)
        localStorage.removeObject(forKey: practiceBundleExpirationDateKey)
        localStorage.synchronize()
        
        
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)

        
        
        let kvStore = NSUbiquitousKeyValueStore.default
        let kvd = kvStore.dictionaryRepresentation
        let arr = kvd.keys
        
        for key in arr {
            kvStore.removeObject(forKey: key)
        }
    }
    
    func setupIAP() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    //let productId: Set = [purchase.productId]
                    HASettings.sharedInstance.setAdsTurnedOff(show: true)
                    HAStoreKitManager.sharedInstance.verifySubscription(productId: purchase.productId)
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    //HAStoreKitManager.sharedInstance.verifyPurchase(purchase.productId)
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if HASettings.sharedInstance.isGameScreenVisible{
            NotificationCenter.default.post(name: Notification.Name("skipCurrentQuestion"), object:nil )
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
