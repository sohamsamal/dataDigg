//
//  HASettingsViewController.swift
//  QuizApp Starter Kit All In One 1.0
//
//

import UIKit
import StoreKit

class HASettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    @IBOutlet weak var settingFontLabel: HACustomLabel!
    @IBOutlet weak var titleView: HACustomLabel!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var removeAdsStackView: UIStackView!
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var removeAdsButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    var soundsSwitch : UISwitch! = nil
    //var showExplanationSwitch : UISwitch! = nil
    
    
    var product : SKProduct!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: homeButton)
        self.navigationItem.titleView = titleView
        navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
        self.tableView.tableFooterView = self.removeAdsStackView.superview!
        self.tableView.tableFooterView?.isHidden = true
        
        
        if HASettings.sharedInstance.isInAppPurchaseSupported
        {
            SKPaymentQueue.default().add(self)
            if let productIdentifier = HASettings.sharedInstance.removeAdsProdcutIdentifier
            {
                if productIdentifier == ""{
                    removeAdsButton.removeFromSuperview()
                    tableView.tableFooterView?.isHidden = false
                }
                else{
                    if HASettings.sharedInstance.isProductPurchased(productIdentifier: HASettings.sharedInstance.removeAdsProdcutIdentifier)
                    {
                        removeAdsButton.removeFromSuperview()
                        tableView.tableFooterView?.isHidden = false
                    }
                    else{
                        let set: Set = [productIdentifier]
                        let request = SKProductsRequest.init(productIdentifiers: set)
                        request.delegate = self
                        request.start()
                    }
                }
            }
            else{
                removeAdsButton.removeFromSuperview()
                tableView.tableFooterView?.isHidden = false
            }
        }
        
        SKStoreReviewController.requestReview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if HASettings.sharedInstance.isInAppPurchaseSupported{
            SKPaymentQueue.default().remove(self)
        }
        
    }
    
    @IBAction func homeAction(_ sender: Any) {
        HAUtilities.playTapSound()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- UITableView Delagtes and Data sources
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = UIColor.init().appTextColor()
        cell.textLabel?.font = settingFontLabel.font
        
        if indexPath.row == 0{
            cell.textLabel?.text = "Sounds"
            if let switchButton = self.soundsSwitch{
                switchButton.removeFromSuperview()
            }
            self.soundsSwitch = UISwitch(frame: CGRect(x: cell.frame.size.width - 51.0, y: cell.frame.size.width/2.0 - 15.0 , width:50.0, height: 31.0))
            
            self.soundsSwitch.setOn(HASettings.sharedInstance.isSoundsOn, animated: false)
            self.soundsSwitch.addTarget(self, action: #selector(soundsSwitch(switchButton:)), for:.valueChanged)
            cell.accessoryView = self.soundsSwitch
        }
        else{
            //cell.textLabel?.text = "Show Answers"
            
            /*if let switchButton = self.showExplanationSwitch
            {
                switchButton.removeFromSuperview()
            }
            self.showExplanationSwitch = UISwitch(frame: CGRect(x: cell.frame.size.width - 51.0, y: cell.frame.size.width/2.0 - 15.0 , width:50.0, height: 31.0))

            self.showExplanationSwitch.setOn(HASettings.sharedInstance.showExplanation, animated: false)
            self.showExplanationSwitch.addTarget(self, action: #selector(explanationSwitch(explanationSwitch:)), for:.valueChanged)
            cell.accessoryView = self.showExplanationSwitch*/
        }
        return cell
    }
    
    
    @objc func soundsSwitch(switchButton: UISwitch)
    {
        HASettings.sharedInstance.setSoundEnabled(sound: switchButton.isOn)
    }
    
    @objc func explanationSwitch(explanationSwitch: UISwitch)
    {
        HASettings.sharedInstance.setShowExplanation(show: explanationSwitch.isOn)
    }

    @IBAction func removeAdsAction(_ sender: Any) {
        HAUtilities.playTapSound()

        if HASettings.sharedInstance.isParentalGateEnabled{
            let numbers = [16,21,14,12,19,40,71,99,56,65,13,26,45]
            let i = Int(arc4random()) % numbers.count
            let number = numbers[i]
            let ansForParentalQuestion = number * 2
            
            let aleretController = UIAlertController(title: "Parental Gate!", message: "What is \(number)x2?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                
            }
            
            let checkAction = UIAlertAction(title: "Check now", style: .default) { (action) in
                let textField = aleretController.textFields![0]
                if ansForParentalQuestion == Int(textField.text!) {
                    self.continueBuy(product: self.product)
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
            
            self.continueBuy(product: self.product)
        }
    }
    
    @IBAction func restoreAction(_ sender: Any) {
        HAUtilities.playTapSound()

        showActivity()
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @objc func removeRemoveAdsButton(){
        if self.removeAdsButton != nil
        {
            self.removeAdsButton.removeFromSuperview()
        }
        self.tableView.tableFooterView?.isHidden = false
    }
    
    @objc func updateUI()
    {
        self.tableView.tableFooterView?.isHidden = false
    }
    
    //MARK:- InApp Purchase methods
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.performSelector(onMainThread: #selector(hideActivity), with: nil, waitUntilDone: true)
        let products = response.products
        if products.count > 0{
            self.product = products.first
            self.performSelector(onMainThread: #selector(updateUI), with: nil, waitUntilDone: true)
        }
        else{
            let alertController = UIAlertController(title: "Oops!", message: "Unable to load or products not found, please try again later", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
    }
    
    private func continueBuy(product: SKProduct!)
    {
        showActivity()
        let request = SKPayment.init(product: product)
        SKPaymentQueue.default().add(request)
        SKPaymentQueue.default().add(self)
        print("buying : \(product.productIdentifier)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.performSelector(onMainThread: #selector(hideActivity), with: nil, waitUntilDone: true)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.performSelector(onMainThread: #selector(hideActivity), with: nil, waitUntilDone: true)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        self.performSelector(onMainThread: #selector(hideActivity), with: nil, waitUntilDone: true)
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
        print("purchased : \(transaction.payment.productIdentifier)")
        if transaction.payment.productIdentifier == HASettings.sharedInstance.removeAdsProdcutIdentifier
        {
            self.performSelector(onMainThread: #selector(removeRemoveAdsButton), with: nil, waitUntilDone: true)
        }
    }
    
    private func restoredTransaction(transaction: SKPaymentTransaction)
    {
        print("restored : \(transaction.payment.productIdentifier)")
        UserDefaults.standard.setValue(transaction.payment.productIdentifier, forKey: transaction.payment.productIdentifier)
        UserDefaults.standard.synchronize()
        
        //Remove remove ads button if already purchased
        if transaction.payment.productIdentifier == HASettings.sharedInstance.removeAdsProdcutIdentifier
        {
            self.performSelector(onMainThread: #selector(removeRemoveAdsButton), with: nil, waitUntilDone: true)
        }
        
    }
    
    private func failedTransaction(transaction: SKPaymentTransaction)
    {
        hideActivity()
    }
    
}
