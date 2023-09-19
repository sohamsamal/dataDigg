//
//  HAPurchaseViewController.swift
//  QuizApp Starter Kit All In One 1.0
//
//

import UIKit
import StoreKit

class HAPurchaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource { //, SKPaymentTransactionObserver  shilpa
    
    

    @IBOutlet var titleView: HACustomLabel!
    //@IBOutlet var restoreButton: HACustomButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var categories : [HACategory]!
    var products: [SKProduct]!
    var dataManager = HAQuizDataManager.sharedInstance
    var ansForParentalQuestion : Int! = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: restoreButton)  //shilpa
        self.navigationItem.titleView = titleView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       /* if HASettings.sharedInstance.isInAppPurchaseSupported{
            SKPaymentQueue.default().remove(self)
        }*/ //shilpa
    }
    
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
    
    private func continueBuy(product: SKProduct!)
    {
        showActivity()
        let request = SKPayment.init(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(request)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.performSelector(onMainThread: #selector(hideActivity), with: nil, waitUntilDone: true)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.performSelector(onMainThread: #selector(hideActivity), with: nil, waitUntilDone: true)
    }
   

    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        hideActivity()
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
        categories = self.dataManager.paidCategories()
        tableView.reloadData()
        
     
        let aleretController = UIAlertController(title: "Purchased!", message: "Your quiz is purchased added to play quiz list", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
        }
        aleretController.addAction(okAction)
        
        if categories.count == 0{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func restoredTransaction(transaction: SKPaymentTransaction)
    {
        UserDefaults.standard.setValue(transaction.payment.productIdentifier, forKey: transaction.payment.productIdentifier)
        UserDefaults.standard.synchronize()
        tableView.reloadData()
    }
    
    private func failedTransaction(transaction: SKPaymentTransaction)
    {
        tableView.reloadData()
    }
    
    @IBAction func restoreAction(_ sender: Any) {
        HAUtilities.playTapSound()
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }*/  //shilpa
    
    private func showSubscriptions(category : HACategory!) {
            let storyboard = UIStoryboard(name: "HAPurchaseList", bundle: nil)
            let showPurchaseVC:HAPurchaseListViewController = (storyboard.instantiateViewController(withIdentifier: "PurchaseListId") as? HAPurchaseListViewController)!
        showPurchaseVC.category = category
        self.navigationController?.pushViewController(showPurchaseVC, animated: true)
    }
    
    //MARK:- TableView delegates and data sources
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UI_USER_INTERFACE_IDIOM() == .pad{
            return 126.0
        }
        return 90.0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("HACategoryCell", owner: self, options: nil)?.first as! HACategoryCell
        cell.accessoryType = .disclosureIndicator        
        cell.highscoreContainerView.isHidden = true
        cell.buyContainerView.isHidden = true
        cell.buyButton.isHidden = true
        //cell.priceLabel.isHidden = false //shilpa
        cell.selectionStyle = .none
//        cell.buyButton.tag = indexPath.row
//        cell.buyButton.addTarget(self, action: #selector(showSubscriptions(sender:)), for: .touchUpInside)
        
        let category = categories[indexPath.row]
        cell.category = category
        cell.backgroundColor = UIColor(hexString: category.themeColorString!)
        
     /*   for product in products
        {
            if product.productIdentifier == category.productIdentifier
            {
                let priceFormatter = NumberFormatter()
                priceFormatter.numberStyle = .currency
                priceFormatter.formatterBehavior = .behavior10_4
                priceFormatter.locale = product.priceLocale
                //cell.priceLabel.text = priceFormatter.string(from: product.price) shilpa
            }
        }*/
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        showSubscriptions(category: category)
    }
}
