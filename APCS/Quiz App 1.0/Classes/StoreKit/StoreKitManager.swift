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

import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

let transactionsFile : String = "transactions.plist"

open class StoreKitManager: NSObject  {

  // MARK: - Properties
  fileprivate let productIdentifiers: Set<ProductIdentifier>
  public var purchasedProducts = Set<ProductIdentifier>()
  fileprivate var productsRequest: SKProductsRequest?
  fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    fileprivate weak var QuizProductsRef:QuizProducts?
  // MARK: - Initializers
    public init(productIds: Set<ProductIdentifier>, QuizProductsReference:QuizProducts) {
    productIdentifiers = productIds
    purchasedProducts = Set(productIds.filter { UserDefaults.standard.bool(forKey: $0) })
    QuizProductsRef = QuizProductsReference
    super.init()
    SKPaymentQueue.default().add(self)
  }
}

// MARK: - StoreKit API
extension StoreKitManager {

  public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
    productsRequest?.cancel()
    productsRequestCompletionHandler = completionHandler

    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productsRequest!.delegate = self
    productsRequest!.start()
  }

  public func buyProduct(_ product: SKProduct) {
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }

  public func isPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
    return purchasedProducts.contains(productIdentifier)
  }

  public class func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments()
  }

  /*public func restorePurchases() {
    // Restore Consumables and Non-Consumables from Apple
    SKPaymentQueue.default().restoreCompletedTransactions()
  }*/
}

// MARK: - SKProductsRequestDelegate
extension StoreKitManager: SKProductsRequestDelegate {
  
  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    let products = response.products
    print("Loaded list of products...")
    productsRequestCompletionHandler?(true, products)
    clearRequestAndHandler()

    for prod in products {
      print("Found product: \(prod.productIdentifier) \(prod.localizedTitle) \(prod.price.floatValue)")
    }
  }

  public func request(_ request: SKRequest, didFailWithError error: Error) {
    print("Failed to load list of products.")
    print("Error: \(error.localizedDescription)")
    productsRequestCompletionHandler?(false, nil)
    clearRequestAndHandler()
  }

  private func clearRequestAndHandler() {
    productsRequest = nil
    productsRequestCompletionHandler = nil
  }
}

// MARK: - SKPaymentTransactionObserver
extension StoreKitManager: SKPaymentTransactionObserver {

  public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .purchased:
        complete(transaction: transaction)
        break
      case .failed:
        fail(transaction: transaction)
        break
      case .restored:
        restore(transaction: transaction)
        break
      case .deferred:
        break
      case .purchasing:
        break
      }
    }
  }

  private func complete(transaction: SKPaymentTransaction) {
    print("complete...")
    print("transaction : \(transaction.transactionIdentifier)")
    
    let transactionID = UserDefaults.standard.object(forKey: transaction.transactionIdentifier!)
    HASettings.sharedInstance.setAdsTurnedOff(show: true)
    if (transactionID == nil) {
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        UserDefaults.standard.set( transaction.transactionIdentifier!, forKey: transaction.transactionIdentifier as! String)
        UserDefaults.standard.synchronize()
    }
    SKPaymentQueue.default().finishTransaction(transaction)
  }

  private func restore(transaction: SKPaymentTransaction) {
    guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
    HASettings.sharedInstance.setAdsTurnedOff(show: false)

    print("restore... \(productIdentifier)")
    //****** this line of code is commented deliverPurchaseNotificationFor(identifier: productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
  }

  private func fail(transaction: SKPaymentTransaction) {
    print("fail...")
    QuizProductsRef!.handleError(errorStr:transaction.error?.localizedDescription ?? " ")

//    if let transactionError = transaction.error as? NSError {
//      if transactionError.code != SKError.paymentCancelled.rawValue {
//        print("Transaction Error: \(transaction.error?.localizedDescription)")
//        QuizProductsRef!.handleError(errorStr:transaction.error?.localizedDescription ?? " ")
//        }
//    }
    SKPaymentQueue.default().finishTransaction(transaction)
  }
  
  private func deliverPurchaseNotificationFor(identifier: String?) {
    guard let identifier = identifier else { return }

    QuizProductsRef!.handlePurchase(productID: identifier)
  }
}
