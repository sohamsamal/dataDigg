//
//  HAStoreKitManager.swift
//  QuizApp Starter Kit All In One 1.0
//

//

import UIKit
import SwiftyStoreKit
import StoreKit

protocol SwiftyStoreKitDelegate: class {
    func showAlert(_ alert: UIAlertController)
    func productDidPurchase(purchaseDetails : PurchaseDetails!)
    func restoreFinished()
}

final class HAStoreKitManager{
    
    static let sharedInstance = HAStoreKitManager()
    weak var delegate: SwiftyStoreKitDelegate?
    private init() {
      
    }
    
    func isSubscriptionExpired(productId:String) -> Bool {
        
        if(UserDefaults.standard.contains(key: productId)) {
            let expiryDate = UserDefaults.standard.object(forKey: productId) as? Date
            if(Date() < expiryDate!) {
                return false
            } else {
                self.removeFromUserDefaults(productId: productId)
            }
        }
        return true
    }
    
    func expiryDate(productId:String) -> Date? {
        if(UserDefaults.standard.contains(key: productId)) {
            let expiryDate = UserDefaults.standard.object(forKey: productId) as? Date
            return expiryDate
        }
        else {
        return nil
        }
            
    }
    
    
    func saveToUserDefaults(productId:String, expiryDate:Date) {
       // if let date = UserDefaults.standard.object(forKey: "expiryDate") as? Date {
            if Date() < expiryDate {
                UserDefaults.standard.set(expiryDate, forKey: productId)
            } else {
                self.removeFromUserDefaults(productId: productId)
        }
        //}
       // UserDefaults.standard.setValue(expiryDate, forKey: productId)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name("handlePurchaseNotification"), object: nil, userInfo: nil)

    }
    
    func removeFromUserDefaults(productId:String) {
        
        if(UserDefaults.standard.contains(key: productId)) {
            UserDefaults.standard.removeObject(forKey: productId)
            NotificationCenter.default.post(name: Notification.Name("handlePurchaseNotification"), object: nil, userInfo: nil)
        }
    }
    
    
    func getInfoOfProducts(category:HACategory, completion: @escaping ([SKProduct]) -> Void) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        let ids = Set(category.subscriptions!)
        SwiftyStoreKit.retrieveProductsInfo(ids) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            let retrievedProducts:[SKProduct] = Array(result.retrievedProducts)
            let alertController = self.alertForProductRetrievalInfo(result)
            if alertController != nil {
                self.delegate?.showAlert(alertController!)                
            }
            completion(retrievedProducts)
            //self.tableView.reloadData()
        }
    }
    
    func purchase(_ purchaseId: String, atomically: Bool) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(purchaseId, atomically: atomically) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if case .success(let purchase) = result {
                
                //let productId: Set = [purchase.productId]
                self.verifySubscription(productId: purchase.productId)
                
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    //HAStoreKitManager.sharedInstance.verifyPurchase(purchase.productId)
                    // self.completeTransaction(transaction: purchase) //shilpa add
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                } //shilpa
                
                if self.delegate != nil {
                    self.delegate?.productDidPurchase(purchaseDetails: purchase)
                }
            }
            if let alert = self.alertForPurchaseResult(result) {
                self.delegate?.showAlert(alert)
            }
        }
    }
    
    func restorePurchases() {
//        if(UserDefaults.standard.contains(key: "FirstTimeLaunch")) {
//            return
//        } else {
//            UserDefaults.standard.setValue("FirstTimeLaunch", forKey: "FirstTimeLaunch")
//            UserDefaults.standard.synchronize()
//        }

        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true, completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            for product in result.restoredPurchases {
                //let productId: Set = [product.productId]

                self.verifySubscription(productId: product.productId)
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
            
            if self.delegate != nil {
                self.delegate?.restoreFinished()
            }
            //self.delegate?.showAlert(self.alertForRestorePurchases(result))
        })
            
    }
    
    func verifySubscription(productId:String) {
        
        let isAutoRenewal = true
        //if productId.range(of:"one") != nil {
         //   isAutoRenewal = false
      //  }
        print("product id: \(productId)")
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: "d84bc7d596fc4a28ad4d24f1049f004d")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            
            if case .success(let receipt) = result {
                var purchaseResult:VerifySubscriptionResult
                if(isAutoRenewal) {
                 purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt)
            } else {
                 purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .nonRenewing(validDuration: 60*5),
                    productId: productId,
                    inReceipt: receipt)
                    //60.0*60.0*24.0*30
            }
                
                switch purchaseResult {
                case .purchased(let expiryDate, let receiptItems):
                    let removeAdsProdID : String! = HASettings.sharedInstance.removeAdsProdcutIdentifier
                    HASettings.sharedInstance.setAdsTurnedOff(show: true)
                UserDefaults.standard.setValue(removeAdsProdID, forKey: removeAdsProdID)
                    UserDefaults.standard.synchronize()

                    print("Product is valid until \(expiryDate)")
                    if let mostRecent = receiptItems.first {
                        self.saveToUserDefaults(productId: mostRecent.productId, expiryDate: expiryDate)
                    }
                case .expired(let expiryDate, let receiptItems):
                    print("Product is expired since \(expiryDate)")
                    if let mostRecent = receiptItems.first {
                        self.removeFromUserDefaults(productId: mostRecent.productId)
                    }
                case .notPurchased:
                    print("This product has never been purchased")
                }
            } else {
                // receipt verification error
            }
        }
    }
}


// MARK: User facing alerts
extension HAStoreKitManager {
    
    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
        
        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
        } else if results.restoredPurchases.count > 0 {
            print("Restore Success: \(results.restoredPurchases)")
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }
    
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    func alertForProductRetrievalInfo(_ result: RetrieveResults) -> UIAlertController? {
        
//        if let product = result.retrievedProducts.first {
//            let priceString = product.localizedPrice!
//            return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
//        } else
        if let invalidProductId = result.invalidProductIDs.first {
            return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
        } else if result.error != nil {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
            return alertWithTitle("Could not retrieve product info", message: errorString)
        }
        return nil
    }
    
    // swiftlint:disable cyclomatic_complexity
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
            return nil
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return alertWithTitle("Purchase failed", message: error.localizedDescription)
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return alertWithTitle("Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return alertWithTitle("Purchase failed", message: "Cloud service was revoked")
            default:
                return alertWithTitle("Purchase failed", message: (error as NSError).localizedDescription)
            }
        }
    }
}

extension HAStoreKitManager {
    //MARK:- InApp Purchase methods
    /* @objc func buyAction(sender: UIButton){
     HAUtilities.playTapSound()
     
     let category = categories[sender.tag]
     if HASettings.sharedInstance.isParentalGateEnabled{
     let numbers = [16,21,14,12,19,40,71,99,56,65,13,26,45]
     let i = Int(arc4random()) % numbers.count
     let number = numbers[i]
     ansForParentalQuestion = number * 2
     
     let aleretController = UIAlertController(title: "Parental Gate!", message: "What is \(number)x2?", preferredStyle: .alert)
     let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
     
     }
     
     let checkAction = UIAlertAction(title: "Check now", style: .default) { (action) in
     let textField = aleretController.textFields![0]
     if self.ansForParentalQuestion == Int(textField.text!) {
     
     if let product = self.products.first(where: {$0.productIdentifier == category.productIdentifier}) {
     self.continueBuy(product: product)
     }
     }
     }
     aleretController.addAction(cancelAction)
     aleretController.addAction(checkAction)
     
     aleretController.addTextField { (texField) in
     
     }
     self.present(aleretController, animated: true) {
     }
     }
     else{
     
     if let product = products.first(where: {$0.productIdentifier == category.productIdentifier}) {
     self.continueBuy(product: product)
     }
     }
     }
     */
    /* private func continueBuy(product: SKProduct!)
     {
     //showActivity()
     let request = SKPayment.init(product: product)
     //SKPaymentQueue.default().add(self)
     SKPaymentQueue.default().add(request)
     }
     
     func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
    // self.performSelector(onMainThread: #selector(hideActivity), with: nil, waitUntilDone: true)
     }
     
     func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
     //self.performSelector(onMainThread: #selector(hideActivity), with: nil, waitUntilDone: true)
     }
     
     
     
     func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
     //hideActivity()
     for transaction in transactions{
     switch (transaction.transactionState)
     {
     case .purchased:
     completeTransaction(transaction: transaction)
     case .failed:
     failedTransaction(transaction: transaction)
     case .restored:
     restoredTransaction(transaction: transaction)
     case .purchasing:
     print("purchasing")
     case .deferred:
     print("transaction in queue")
     
     }
     }
     }
     
     private func completeTransaction(transaction: SKPaymentTransaction)
     {
     
     UserDefaults.standard.setValue(transaction.payment.productIdentifier, forKey: transaction.payment.productIdentifier)
     UserDefaults.standard.synchronize()
     //categories = self.dataManager.paidCategories()
     //tableView.reloadData()
     
     
     let aleretController = UIAlertController(title: "Purchased!", message: "Your quiz is purchased added to play quiz list", preferredStyle: .alert)
     let okAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
     }
     aleretController.addAction(okAction)
     
     if categories.count == 0{
     //self.navigationController?.popViewController(animated: true)
     }
     }
     
     private func restoredTransaction(transaction: SKPaymentTransaction)
     {
     UserDefaults.standard.setValue(transaction.payment.productIdentifier, forKey: transaction.payment.productIdentifier)
     UserDefaults.standard.synchronize()
    // tableView.reloadData()
     }
     
     private func failedTransaction(transaction: SKPaymentTransaction)
     {
     //tableView.reloadData()
     }
     
     @IBAction func restoreAction(_ sender: Any) {
     HAUtilities.playTapSound()
    // SKPaymentQueue.default().add(self)
     SKPaymentQueue.default().restoreCompletedTransactions()
    }*/
    
}














