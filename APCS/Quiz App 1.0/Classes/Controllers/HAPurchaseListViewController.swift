//
//  HAPurchaseListViewController.swift
//  QuizApp Starter Kit All In One 1.0
//
//

import UIKit
import SwiftyStoreKit
import StoreKit

class HAPurchaseListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var includesLabel: UILabel!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var subscriptionForLabel: UILabel!
    @IBOutlet var tableView:UITableView!
    var QuizProductsRef:QuizProducts?
    //var subscriptionsForCategory:[String:String] = [String:String]()
    var category:HACategory = HACategory()
    var retrievedProducts:[SKProduct] = [SKProduct]()
   //let subscriptionDurations:[String] = ["$2.99/month", "$4.99/three months", "$6.99/six months"]
    let subscriptionDurations:[String] = [" - one month", " - two months", " - three months"]
    //let buttonNamesBeforeBuy:[String] = ["  Subscribe  ", "  Subscribe  ", "  Subscribe  "]
    //let buttonNamesAfterBuy:[String] = ["  Subscribed  ", "  Subscribed  ", "  Subscribed  "]
    //var validProductId:String!
    //var showPurchaseButton : Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instructionsTextView.setContentOffset(.zero, animated: false)
        
        var questionsCount = 65 //65 for category.id == 2
//        if (category.id == "3" ) {
//            questionsCount = 130
//        }
        
//        includesLabel.text = "Each subscription gives access to a Practice Test for Series 65 exam. It contains \(questionsCount) questions, answers, and explanations. Also ad free experience."
        
        tableView.backgroundColor = .clear
        
        tableView.delegate = self
        tableView.dataSource = self
        //showPurchaseButton = false
        //HAStoreKitManager.sharedInstance.delegate = self
        self.title = "\(String(describing: category.name!))"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.subscriptionForLabel.text = "Subscription for " + "\(String(describing: category.name!))"
        let rightBarButtonItem = UIBarButtonItem(title: "Restore", style: UIBarButtonItem.Style.plain, target: self, action: #selector(restoreButtonTapped))
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
        //showActivity()
        /*HAStoreKitManager.sharedInstance.getInfoOfProducts(category: category) { (results) in
            self.hideActivity()
            self.retrievedProducts = results
            self.getGreaterExpiryDate()
            self.showPurchaseButton = true
            self.tableView.reloadData()
        }*/
        self.requestProducts()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.handlePurchaseNotification(notification:)), name: Notification.Name("handlePurchaseNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseNotification),
                                               name: NSNotification.Name(rawValue: QuizProductsPurchaseNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseErrorNotification),
                                               name: NSNotification.Name(rawValue: QuizProductsPurchaseErrorNotification),
                                               object: nil)
        // Do any additional setup after loading the view.
    }
    
    func requestProducts() {
        showActivity()
        let productIds = Set(category.subscriptions!)

        QuizProductsRef = QuizProducts(productIds: productIds)
        QuizProductsRef!.store!.requestProducts { [unowned self] success, products in
            if success, let products = products {
                DispatchQueue.main.async {
                    self.retrievedProducts = products
                    self.tableView.reloadData()
                }
            }
            self.hideActivity()
        }
    }
    
    @IBAction func privacyAction(_ sender: Any) {
        if let url = URL(string: "https://datadigg.com/about/privacy-policy/"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func termsAction(_ sender: Any) {
        if let url = URL(string: "https://datadigg.com/about/terms-of-service/"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func handlePurchaseNotification(notification: Notification) {
        //self.tableView.reloadData()
        DispatchQueue.main.async { [weak self] in
            self?.hideActivity()
            let alertController = UIAlertController(title: "Purchased!", message: "Your quiz is purchased added to play quiz list", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { (okAction) in
                self?.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action)
            self?.present(alertController, animated: true, completion: nil)
            self?.tableView.reloadData()
        }
        
    }
    
    @objc func handlePurchaseErrorNotification(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.hideActivity()
            let alertController = UIAlertController(title: "Purchase failed!", message: notification.object as? String, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { (okAction) in
                self?.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action)
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
   
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @objc func restoreButtonTapped() {
       // HAStoreKitManager.sharedInstance.restorePurchases()
        //QuizProductsRef!.store!.restorePurchases()
        QuizProducts.RefreshAll()
        self.tableView.reloadData()

    }
    
    func beginPurchase(product:SKProduct) {
        showActivity()
       // if let product = self.retrievedProducts.first(where: {$0.productIdentifier == productId}) {
            QuizProductsRef!.store!.buyProduct(product)
    }
    
    //MARK:- TableView delegates and data sources
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return category.subscriptions!.count
        return self.retrievedProducts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UI_USER_INTERFACE_IDIOM() == .pad{
            return 110.0
        }
        return 50.0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PurchaseViewCell = (tableView.dequeueReusableCell(withIdentifier: "PurchaseViewCellId", for: indexPath) as? PurchaseViewCell)!
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.parent = self
       /* cell.subScribeButton.isHidden = !showPurchaseButton
      //  cell.priceText.isHidden = !showPurchaseButton
        
        cell.subScribeButton.addTarget(self, action: #selector(beginPurchase(sender:)), for: .touchUpInside)
      //  cell.durationText.text = subscriptionDurations[indexPath.row]
        cell.subScribeButton.setTitle(self.buttonNamesBeforeBuy[indexPath.row],for: .normal)
        cell.subScribeButton.backgroundColor = UIColor.blue
        cell.category = category
        //let category = categories[indexPath.row]
        for product in self.retrievedProducts
        {
            if product.productIdentifier == category.subscriptions![indexPath.row]
            {
            
                let priceFormatter = NumberFormatter()
                priceFormatter.numberStyle = .currency
                priceFormatter.formatterBehavior = .behavior10_4
                priceFormatter.locale = product.priceLocale
              //  print (priceFormatter.string(from: product.price), subscriptionDurations[indexPath.row])
               // cell.durationText.text = priceFormatter.string(from: product.price)
                cell.durationText.text = priceFormatter.string(from: product.price)! +  subscriptionDurations[indexPath.row]
               // cell.priceText.text = priceFormatter.string(from: product.price)
                //if (UserDefaults.standard.value(forKey: product.productIdentifier) as? String) != nil{
               /* let isExpired = HAStoreKitManager.sharedInstance.isSubscriptionExpired(productId: product.productIdentifier)
                if(!isExpired) {*/
                if(product.productIdentifier == self.validProductId) {
                    cell.subScribeButton.setTitle(" Subscribed ",for: .normal)
                    cell.subScribeButton.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "optionBg_green"))
                    cell.subScribeButton.isEnabled = false
                }
            }
        }*/
        
        //let product = self.retrievedProducts[(indexPath as NSIndexPath).row]
        for product in self.retrievedProducts
        {
            if product.productIdentifier == category.subscriptions![indexPath.row]
            {
                cell.product = product
            }
        }
        cell.rowNumber = indexPath.row
        cell.buyButtonHandler = { product in
            self.beginPurchase(product:product )
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let category = categories[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var expirationDateKey:String?
        if(category.name.contains("1")) {
            expirationDateKey = practice1ExpirationDateKey
        } else if(category.name.contains("2")) {
            expirationDateKey = practice2ExpirationDateKey
        } else if(category.name.contains("3")) {
                  expirationDateKey = practice3ExpirationDateKey
        } else if(category.name.contains("4")) {
              expirationDateKey = practice4ExpirationDateKey
            } else if(category.name.contains("5")) {
                      expirationDateKey = practice5ExpirationDateKey
            } else if(category.name.contains("Bundle")) {
                      expirationDateKey = practiceBundleExpirationDateKey
          }
        if(expirationDateKey != nil) {
        let expiryDateString = QuizProducts.getExpiryDateString(expirationDateKey: expirationDateKey!)
        return expiryDateString
        }
        return " "
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        var expirationDateKey:String?
        if(category.name.contains("1")) {
            expirationDateKey = practice1ExpirationDateKey
        } else if(category.name.contains("2")) {
            expirationDateKey = practice2ExpirationDateKey
        }else if(category.name.contains("3")) {
            expirationDateKey = practice3ExpirationDateKey
        }else if(category.name.contains("4")) {
            expirationDateKey = practice4ExpirationDateKey
        }else if(category.name.contains("5")) {
            expirationDateKey = practice5ExpirationDateKey
        }else if(category.name.contains("Bundle")) {
            expirationDateKey = practiceBundleExpirationDateKey
        }
        if(expirationDateKey != nil) {
            let expiryDateString = QuizProducts.getExpiryDateString(expirationDateKey: expirationDateKey!)
            if expiryDateString.count <= 1 {
                return 0
            }
        }
        if UI_USER_INTERFACE_IDIOM() == .pad{
            return 70.0
        }
        return 44.0
        
    }
    /*******************************************/
    /*private func completeTransaction(transaction: PurchaseDetails)
     {
     
     UserDefaults.standard.setValue(transaction.productId, forKey: transaction.productId)
     UserDefaults.standard.synchronize()
     //categories = self.dataManager.paidCategories()
     tableView.reloadData()
     
     
     let aleretController = UIAlertController(title: "Purchased!", message: "Your quiz is purchased added to play quiz list", preferredStyle: .alert)
     let okAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
     }
     aleretController.addAction(okAction)
     
     /*if categories.count == 0{
     self.navigationController?.popViewController(animated: true)
     }*/
     }*/
    
    func restoreFinished() {
        
    }
    
    /*func productDidPurchase(purchaseDetails : PurchaseDetails!) {
        self.hideActivity()        
        let alertController = UIAlertController(title: "Subscribed", message: "\(purchaseDetails.product.localizedTitle) Practice Test has been added to you play quiz list!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (okAction) in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)

    }*/
    
    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            self.hideActivity()
            self.present(alert, animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            return
        }
    }
}
