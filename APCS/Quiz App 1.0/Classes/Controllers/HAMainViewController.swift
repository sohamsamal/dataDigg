//
//  HAMainViewController.swift
//  Quiz App Starter Kit All In One 1.0
//
//
//

import UIKit
import GameKit
import StoreKit
import GoogleMobileAds
import SwiftyStoreKit

class HAMainViewController: UIViewController, GKGameCenterControllerDelegate, GADBannerViewDelegate {

    let dataManager = HAQuizDataManager.sharedInstance
    @IBOutlet weak var titleLabel: HACustomLabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var playQuizButton: UIButton!
    @IBOutlet weak var multiplayerButton: UIButton!
    @IBOutlet weak var moreCategoriesButton: UIButton!
    @IBOutlet weak var worldScoresButton: UIButton!
    @IBOutlet weak var menusStackView: UIStackView!
    @IBOutlet weak var tutoringButton: HACustomButton!
    
    var bannerView: GADBannerView!
    let vc = HAGameViewController()
    //vc.remainingSeconds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = HASettings.sharedInstance.menuScreenTittle
        self.navigationItem.titleView = titleLabel
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: infoButton)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: settingsButton)
        
        settingsButton.isExclusiveTouch = true
        infoButton.isExclusiveTouch = true
        playQuizButton.isExclusiveTouch = true
        tutoringButton.isExclusiveTouch = true
        multiplayerButton.isExclusiveTouch = true
        worldScoresButton.isExclusiveTouch = true
        
        
        playQuizButton.layer.cornerRadius = 10
        playQuizButton.layer.borderWidth = 1
        
        tutoringButton.layer.borderWidth = 1
        tutoringButton.layer.cornerRadius = 10
        tutoringButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        //using bigger icons for iPad
        if UIUserInterfaceIdiom.pad == UI_USER_INTERFACE_IDIOM(){
            playQuizButton.setImage(#imageLiteral(resourceName: "play_button_icon_ipad"), for: .normal)
            tutoringButton.setImage(#imageLiteral(resourceName: "challenge_button_icon_ipad"), for: .normal)
            multiplayerButton.setImage(#imageLiteral(resourceName: "challenge_button_icon_ipad"), for: .normal)
            moreCategoriesButton.setImage(#imageLiteral(resourceName: "getmore_icon_ipad"), for: .normal)
            worldScoresButton.setImage(#imageLiteral(resourceName: "world_score_button_icon_ipad"), for: .normal)
        }
        
        var hiddenCount = 0
        
        
        
        
        if HASettings.sharedInstance.isMultiplayerSupportEnabled == false{
            multiplayerButton.removeFromSuperview()
            //menusStackView.removeArrangedSubview(multiplayerButoon)
            multiplayerButton = nil
            //multiplayerButoon.isHidden = true
            hiddenCount += 1
        }
        
        
        if HASettings.sharedInstance.isInAppPurchaseSupported == false{
            moreCategoriesButton.removeFromSuperview()
            //menusStackView.removeArrangedSubview(moreCategoriesButton)
            hiddenCount += 1
        }
        
        if HASettings.sharedInstance.isGameCenterSupported == false{
            worldScoresButton.removeFromSuperview()
            if multiplayerButton != nil{
                if multiplayerButton.superview != nil{
                    //menusStackView.removeArrangedSubview(multiplayerButoon)
                    multiplayerButton.removeFromSuperview()
                    hiddenCount += 1
                }
            }
            hiddenCount += 1
        }
        
        for _ in 0..<hiddenCount{
            let view = UIView()
            view.alpha = 0.0
            menusStackView.addArrangedSubview(view)
        }
        
        let ads = GADMobileAds.sharedInstance()
        ads.start { [self] status in
              // Optional: Log each adapter's initialization latency.
              let adapterStatuses = status.adapterStatusesByClassName
              for adapter in adapterStatuses {
                let adapterStatus = adapter.value
                NSLog("Adapter Name: %@, Description: %@, Latency: %f", adapter.key,
                adapterStatus.description, adapterStatus.latency)
              }

                
                bannerView = GADBannerView(adSize: kGADAdSizeBanner)

                addBannerViewToView(bannerView)
                bannerView.adUnitID = "ca-app-pub-8358263348683173/1000374607"
                bannerView.rootViewController = self

                bannerView.load(GADRequest())

                bannerView.delegate = self
            }
        
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: bottomLayoutGuide,
                              attribute: .top,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if HASettings.sharedInstance.requireAdsDisplay(){
            //bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            //HASettings.sharedInstance.showAdmobBannerAd(for: bannerView, onController: self)
            
            
            
            //loadBannerAd()
        } else {
            if bannerView != nil {
                bannerView.removeFromSuperview()
            }
        }
    }
    /*override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        //loadBannerAd()
      }*/
        
    /*override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let adSize = getFullWidthAdaptiveSize()
    }*/
    
    func getFullWidthAdaptiveSize() -> GADAdSize {
        let frame = { () -> CGRect in
            if #available(iOS 11.0, *) {
                return self.view.frame.inset(by: self.view.safeAreaInsets)
            } else {
                return self.view.frame
            }
        }()
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(frame.size.width)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in self.loadBannerAd()})
    }
    
    func loadBannerAd() {
        let frame = { () -> CGRect in
            if #available(iOS 11.0, *) {
                return self.view.frame.inset(by: self.view.safeAreaInsets)
            } else {
                return self.view.frame
            }
        }()
        let viewWidth = frame.size.width
     
        bannerView.adSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
     
        bannerView.load(GADRequest())
    }
    
       /* //restore purchases for first time app launch
        let storeKit = HAStoreKitManager.sharedInstance //this calls init method->restorePurchases
        storeKit.delegate = self
        showActivity()
        storeKit.restorePurchases()
        
    }
    
    func restoreFinished() {
        hideActivity()
    }
    
    func showAlert(_ alert: UIAlertController) {
        
    }*/
    
   /* func productDidPurchase(purchaseDetails : PurchaseDetails!) {
        let alertController = UIAlertController(title: "Subscribed", message: "\(purchaseDetails.product.localizedTitle) quiz has been added to you play quiz list!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (okAction) in
            
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }*/

    
    @IBAction func tutoringButton(_ sender: Any) {
        HAUtilities.playTapSound()
        let storyboard = UIStoryboard(name: "HADiscordViewController", bundle: nil)
        let showDiscord:HADiscordViewController = (storyboard.instantiateViewController(withIdentifier: "DiscordId") as? HADiscordViewController)!
        self.navigationController?.pushViewController(showDiscord, animated: true)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func playQuizAction(_ sender: Any) {
        HAUtilities.playTapSound()
        let controller = HACategoriesViewController.init(nibName: "HACategoriesViewController", bundle: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    @IBAction func multiplayerAction(_ sender: Any) {
        HAUtilities.playTapSound()
    }
    
    
    @IBAction func moreCategoriesAction(_ sender: Any) {
        HAUtilities.playTapSound()
        
        if isNetworkAvailable() {
            let controller = HAPurchaseViewController.init(nibName:"HAPurchaseViewController" , bundle: nil)
            controller.categories = dataManager.paidCategories()
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
     /*   if isNetworkAvailable(){
            showActivity()
            let categoriesForPay = dataManager.paidCategories()
            if let categories = categoriesForPay{
                let productIdentifiers = categories.map { $0.productIdentifier } as! [String]
                let request = SKProductsRequest.init(productIdentifiers: Set(productIdentifiers))
                request.delegate = self
                request.start()
            }
        }
        else{
            
        }*/
    }
    
    @IBAction func worldScoresAction(_ sender: Any) {
        if isNetworkAvailable() && GKLocalPlayer.local.isAuthenticated{
            HAUtilities.playTapSound()
            let controller = GKGameCenterViewController.init()
            controller.gameCenterDelegate = self
            controller.viewState = .leaderboards
            self.present(controller, animated: true) {
            }
        }
        else{
            let alertController = UIAlertController(title: "Oops!", message: "You have not logged in to Game Center.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true) {
        }
    }
    
    
    
    @IBAction func settingsAction(_ sender: Any) {
        HAUtilities.playTapSound()
        let controller = HASettingsViewController.init(nibName:"HASettingsViewController" , bundle: nil)
        let navController = UINavigationController.init(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func infoAction(_ sender: Any) {
        HAUtilities.playTapSound()
        let controller = HAInfoViewController.init(nibName: "HAInfoViewController", bundle: nil)
        let navController = UINavigationController.init(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
    }
    
    //MARK:- InApp purchase delagtes
    /*func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        hideActivity()
        let products = response.products
        if products.count > 0{
            let controller = HAPurchaseViewController.init(nibName:"HAPurchaseViewController" , bundle: nil)
            controller.categories = dataManager.paidCategories()
            controller.products = products
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else{
            let alertController = UIAlertController(title: "Oops!", message: "Unable to load or products not found, please try again later", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
    }*/
}
