//
//  PurchaseViewCell.swift
//  QuizApp Starter Kit All In One 1.0
//
//

import UIKit
import StoreKit

class PurchaseViewCell: UITableViewCell {

    @IBOutlet var durationText:UILabel!
    @IBOutlet var priceText:UILabel!
    @IBOutlet var subScribeButton:UIButton!
    weak var parent:HAPurchaseListViewController!
    //var category:HACategory = HACategory()
   /* @IBAction func subScribeButtonClicked(_ sender:Any) {
        
    }*/
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var buyButtonHandler: ((_ product: SKProduct) -> ())?
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var product: SKProduct? {
        didSet {
            guard let product = product else { return }
            
            // Set button handler
            if subScribeButton.allTargets.count == 0 {
                subScribeButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
            }
            
            // See if Random product
            //imgRandom.isHidden = (product.productIdentifier != OwlProducts.randomProductID)
            
            //lblProductName.text = product.localizedTitle
            //self.parent.QuizProductsRef!.store!.productIDsNonRenewing.contains(product.productIdentifier) {
                //subScribeButton.isHidden = false
                self.subScribeButton.backgroundColor = UIColor.blue
                
            if self.parent.QuizProductsRef!.daysRemainingOnProductId(productId:product.productIdentifier) > 0 {
                self.subScribeButton.setTitle(" Purchased ",for: .normal)
                self.subScribeButton.backgroundColor = UIColor.systemGreen
                self.subScribeButton.isEnabled = false
                } else {
                    subScribeButton.setTitle("  Buy   ", for: .normal)
                    self.subScribeButton.isEnabled = true
                }
                
            PurchaseViewCell.priceFormatter.locale = product.priceLocale
                //lblPrice.text = ProductCell.priceFormatter.string(from: product.price)
            
           /* } else if IAPHelper.canMakePayments() {
                ProductCell.priceFormatter.locale = product.priceLocale
                lblPrice.text = ProductCell.priceFormatter.string(from: product.price)
                
                btnBuy.isHidden = false
                imgCheckmark.isHidden = true
                btnBuy.setTitle("Buy", for: .normal)
                btnBuy.setImage(UIImage(named: "IconBuy"), for: .normal)
            } else {
                lblPrice.text = "Not available"
                btnBuy.isHidden = true
                imgCheckmark.isHidden = true
            }*/
        }
        
    }
    
    //"/month", "/three months", "/six months"
    var rowNumber: Int? {
        didSet {
            /*var stringToAppend = ""
            if(product!.productIdentifier.contains("one.month")) {
                stringToAppend = "/month"
            } else if(product!.productIdentifier.contains("three.month")) {
                stringToAppend = "/three months"
            } else if(product!.productIdentifier.contains("six.month"))  {
                stringToAppend = "/six months"
            }*/
            self.durationText.text = PurchaseViewCell.priceFormatter.string(from: product!.price)! + self.parent.subscriptionDurations[rowNumber!]
        }
    }
    
    @objc func buyButtonTapped(_ sender: AnyObject) {
        buyButtonHandler?(product!)
    }
}
