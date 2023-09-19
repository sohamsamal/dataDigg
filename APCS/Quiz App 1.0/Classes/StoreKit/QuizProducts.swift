/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

let practice1ExpirationDateKey = "practice1ExpirationDateKey"
let practice2ExpirationDateKey = "practice2ExpirationDateKey"
let practice3ExpirationDateKey = "practice3ExpirationDateKey"
let practice4ExpirationDateKey = "practice4ExpirationDateKey"
let practice5ExpirationDateKey = "practice5ExpirationDateKey"
let practiceBundleExpirationDateKey = "practiceBundleExpirationDateKey"
let QuizProductsPurchaseNotification = "QuizProductsPurchaseNotification"
let QuizProductsPurchaseErrorNotification = "QuizProductsPurchaseErrorNotification"

public class QuizProducts {
    
    var productIDsNonRenewing:Set<ProductIdentifier>?
    
    //public static let store = StoreKitManager(productIds: QuizProducts.productIDsNonRenewing)
    var store:StoreKitManager?
    
    public init(productIds: Set<ProductIdentifier>) {
        self.productIDsNonRenewing = productIds
        self.store = StoreKitManager(productIds: productIds,QuizProductsReference:self)
    }
    
    func resourceName(for productIdentifier: String) -> String? {
        return productIdentifier.components(separatedBy: ".").last
    }
    
    func clearProducts() {
        self.store!.purchasedProducts.removeAll()
    }
    
    func daysRemainingOnProductId(productId:String) -> Int {
        return QuizProducts.daysRemainingOnSubscription(expirationDateKey:productId)
    }
    
    class func daysRemainingOnSubscription(expirationDateKey:String) -> Int {
        if  let updatedDate = UserDefaults.standard.object(forKey: expirationDateKey) as? Date
        {
            let numberOfDaysRemaining = updatedDate.interval(ofComponent: .day, fromDate: Date())
            return numberOfDaysRemaining
        }
        return 0
    }
    
    
    
    public static func getExpiryDateString(expirationDateKey:String) -> String {
        let remaining = daysRemainingOnSubscription(expirationDateKey: expirationDateKey)
        if remaining > 0 ,
            let expiryDate = UserDefaults.standard.object(forKey: expirationDateKey) as? Date
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            return "Expires in: \(dateFormatter.string(from: expiryDate as! Date)) (\(remaining) Days)"
        }
        //return "Not Subscribed"
        return " "
    }
   
    
    /*func syncExpiration(productID:String) {
        self.saveSubscriptionByProductIdentifier(productId:productID)
        QuizProducts.syncExpirationOnProductId(productId: productID)
    }*/
    
    class func syncExpirationOnExpirationDateKey(expirationDateKey:String) {
        
        // #if USE_ICLOUD_STORAGE
        let storage:NSUbiquitousKeyValueStore  = NSUbiquitousKeyValueStore.default
        //#else
        let localStorage:UserDefaults = UserDefaults.standard;
        //#endif
        
        let remoteExpiration = storage.object(forKey: expirationDateKey) as? Date
        let local = localStorage.object(forKey: expirationDateKey) as? Date
        // Get to latest date between iCloud and local.
        var latestDate: Date?
        if remoteExpiration == nil {
            latestDate = local
        } else if local == nil {
            latestDate = remoteExpiration
        } else if remoteExpiration!.compare(local!) == .orderedDescending {
            latestDate = remoteExpiration
        } else {
            latestDate = local
        }
        
        if let latestDate = latestDate {
            // Update local
            localStorage.set(latestDate, forKey: expirationDateKey)
            localStorage.synchronize()

            // See if subscription valid
            if latestDate.compare(Date()) == .orderedDescending {
            }
        }
    }
    
    class func RefreshAll() {
        QuizProducts.syncExpirationOnExpirationDateKey(expirationDateKey: practice1ExpirationDateKey)
        QuizProducts.syncExpirationOnExpirationDateKey(expirationDateKey: practice2ExpirationDateKey)
         QuizProducts.syncExpirationOnExpirationDateKey(expirationDateKey: practice3ExpirationDateKey)
         QuizProducts.syncExpirationOnExpirationDateKey(expirationDateKey: practice4ExpirationDateKey)
         QuizProducts.syncExpirationOnExpirationDateKey(expirationDateKey: practice5ExpirationDateKey)
         QuizProducts.syncExpirationOnExpirationDateKey(expirationDateKey: practiceBundleExpirationDateKey)
        let paidCategories = HAQuizDataManager.sharedInstance.paidCategories()
        if(paidCategories?.count == 0)
        {
            return
        }
        for category in paidCategories! {
       
            let productIds = Set(category.subscriptions!)
            for productID in productIds {
                //QuizProducts.syncExpirationOnProductId(productId: productID)
         QuizProducts.syncExpirationOnExpirationDateKey(expirationDateKey: productID)
                
            }
        }

    }
    
    func validExpirationKeyString(productId:String) -> String? {
        
        var expirationDateKey:String?
        
        
        
        if productId.contains("1") {
            expirationDateKey = practice1ExpirationDateKey
        }
        else if productId.contains("practice2") {
            expirationDateKey = practice2ExpirationDateKey
        }
        else if productId.contains("practice3") {
            expirationDateKey = practice3ExpirationDateKey
        }
        else if productId.contains("practice4") {
            expirationDateKey = practice4ExpirationDateKey
        }
        else if productId.contains("practice5") {
            expirationDateKey = practice5ExpirationDateKey
        }
        else if productId.contains("practiceBundle") {
            expirationDateKey = practiceBundleExpirationDateKey
        }
        return expirationDateKey
    }
    
    func increaseRandomExpirationDate(byMonths:Int, expirationDateKey:String, productId:String) {
        let expirationDate = UserDefaults.standard.object(forKey: expirationDateKey)
        let lastDate = expirationDate ?? Date()
        let newDate = Calendar.current.date(byAdding: .month, value: byMonths, to: lastDate as! Date)
        UserDefaults.standard.set(newDate, forKey: expirationDateKey)
        //save tthe same expiration date for productId
        UserDefaults.standard.set(newDate, forKey: productId)
        UserDefaults.standard.synchronize()
    }
    
    func handleMonthlySubscription(months: Int, productID:String) {
        // Update local and Parse with new subscription.
        let expirationDateKey = self.validExpirationKeyString(productId:productID)
        //self.syncExpiration(productID: productID)
        //this is for practice 1/practice 2
    QuizProducts.syncExpirationOnExpirationDateKey(expirationDateKey: expirationDateKey!)
        //this is for individual product ids present in practice 1, practice 2
    QuizProducts.syncExpirationOnExpirationDateKey(expirationDateKey: productID)
    
        // Increase local and save it locally for both productId and expirationKey
        self.increaseRandomExpirationDate(byMonths: months , expirationDateKey:expirationDateKey!, productId:productID)
        // self.setRandomProduct(with: true, productId:productID)
    
        let updatedDate = UserDefaults.standard.object(forKey: expirationDateKey!)
        
        //update iCloud with latest expiray date stored in userdefaults
        let storage:NSUbiquitousKeyValueStore  = NSUbiquitousKeyValueStore.default
        storage.set(updatedDate, forKey: expirationDateKey!)
        //do the same for productId
        storage.set(updatedDate, forKey: productID)
        storage.synchronize()
        
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: QuizProductsPurchaseNotification), object: nil)
    }
    
    func saveSubscriptionByProductIdentifier(productId:String) {
        //#else
        let localStorage:UserDefaults = UserDefaults.standard;
        //#endif
        let currentDate = Date()
        var months = 0
        if(productId.contains("one.month")) {
            months = 1
        } else if(productId.contains("three.month") ){
            months = 2
        }else if(productId.contains("six.month")) {
            months = 3
        }
        let newDate = Calendar.current.date(byAdding: .month, value: months, to: currentDate )!
        localStorage.set(newDate, forKey: productId)
        localStorage.synchronize()
        
    }
    
  /*  class func syncExpirationOnProductId(productId:String) {
        let storage:NSUbiquitousKeyValueStore  = NSUbiquitousKeyValueStore.default
        let localStorage:UserDefaults = UserDefaults.standard;
        
        let remoteExpiration = storage.object(forKey: productId) as? Date
        let local = localStorage.object(forKey: productId) as? Date
        
        // Get to latest date between iCloud and local.
        var latestDate: Date?
        if remoteExpiration == nil {
            latestDate = local
        } else if local == nil {
            latestDate = remoteExpiration
        } else if remoteExpiration!.compare(local!) == .orderedDescending {
            latestDate = remoteExpiration
        } else {
            latestDate = local
        }
        
        if let latestDate = latestDate {
            // Update local and remote
            localStorage.set(latestDate, forKey: productId)
            //storage.set(latestDate, forKey: productId)
            // See if subscription valid
            if latestDate.compare(Date()) == .orderedDescending {
            }
            //storage.synchronize()
            localStorage.synchronize()
        }
    }*/
    
    
    func handlePurchase(productID: String) {
        if self.productIDsNonRenewing!.contains(productID), productID.contains("one.month") {
            self.handleMonthlySubscription(months: 1, productID:productID)
        } else if self.productIDsNonRenewing!.contains(productID), productID.contains("three.month") {
            self.handleMonthlySubscription(months: 2, productID:productID)
        }
        else if self.productIDsNonRenewing!.contains(productID), productID.contains("six.month") {
            self.handleMonthlySubscription(months: 3, productID:productID)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: QuizProductsPurchaseNotification), object: nil)
        
    }
    
    func handleError(errorStr:String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: QuizProductsPurchaseErrorNotification), object: errorStr)
    }
}
