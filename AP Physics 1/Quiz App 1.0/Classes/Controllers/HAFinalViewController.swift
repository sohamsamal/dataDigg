//
//  HAFinalViewController.swift
//  Quiz App Starter Kit All In One 1.0
//
//  Created by Satish Nerlekar on 11/05/18.
//  Copyright © 2018 Heavenapps. All rights reserved.
//

import UIKit
import GoogleMobileAds
import GameKit

class HAFinalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADFullScreenContentDelegate, GKGameCenterControllerDelegate {
    
    

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var leaderboardsButton: UIButton!
    @IBOutlet weak var youScoredLabel: HACustomLabel!
    
    @IBOutlet var titleView: HACustomLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var homeButton: UIButton!
    
    let dataManager : HAQuizDataManager
    var category : HACategory!
    var highscores : NSMutableArray = []
    var categories :[HACategory]!
    var score : Int64 = 0
    
    var interstitial: GADInterstitialAd?

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.dataManager = HAQuizDataManager.sharedInstance
        categories = dataManager.categoriesForPlay()

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManager.setHighScore(score: score, category: category)
        tableView.register(UINib.init(nibName: "HAScoreTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        self.view.backgroundColor = UIColor.init(hexString: category.themeColorString!)
        
        titleView.text = category.name
        self.navigationItem.titleView = titleView
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: homeButton)
        self.youScoredLabel.text = "You scored \(score) points" //***** Change text you required and do not remove \(score) its replacement for score value
        
        if HASettings.sharedInstance.requireAdsDisplay(){
            let ads = GADMobileAds.sharedInstance()
            ads.start { [self] status in
                  // Optional: Log each adapter's initialization latency.
                  let adapterStatuses = status.adapterStatusesByClassName
                  for adapter in adapterStatuses {
                    let adapterStatus = adapter.value
                    NSLog("Adapter Name: %@, Description: %@, Latency: %f", adapter.key,
                    adapterStatus.description, adapterStatus.latency)
                  }

                let request = GADRequest()
                    GADInterstitialAd.load(withAdUnitID:"ca-app-pub-8358263348683173/9129768721",
                                                request: request,
                                      completionHandler: { [self] ad, error in
                                        if let error = error {
                                          print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                          return
                                        }
                                        interstitial = ad
                                        interstitial?.fullScreenContentDelegate = self
                                      }
                    )
                    
                }
            
            /*interstitial = GADInterstitial(adUnitID: kAdmobFullScreenAdUnitID)
            interstitial.delegate = self
            let request = GADRequest()
            interstitial.load(request)*/
        }
        
        if HASettings.sharedInstance.isGameCenterSupported{
            guard let leaderboardID = category.leaderboardID else {
                let alertController = UIAlertController(title: "", message: "Game center feature is enabled in Configuration.plist file abd leaderboard id is not added for the category named \(String(describing: category.name))", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                return
            }
            
            if GKLocalPlayer.local.isAuthenticated && score > 0{
                let leaderboardRequest = GKLeaderboard(players: [GKLocalPlayer.local])
                leaderboardRequest.timeScope = .allTime
                leaderboardRequest.playerScope = .global
                leaderboardRequest.identifier = leaderboardID
                
                leaderboardRequest.loadScores { (scores, error) in
                    guard let unwrappedGKScore = leaderboardRequest.localPlayerScore else{
                        return
                    }
                    self.score += unwrappedGKScore.value
                    
                    let gameScore = GKScore(leaderboardIdentifier: leaderboardID, player: GKLocalPlayer.local)
                    gameScore.value = self.score
                    
                    GKScore.report([gameScore], withCompletionHandler: { (error) in
                        
                    })
                }
            }
        }
        
        //SKStoreReviewController.requestReview()
        
    }
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad did present full screen content.")
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
      print("Ad failed to present full screen content with error \(error.localizedDescription).")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad did dismiss full screen content.")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        dataManager.setHighScore(score: score, category: category)
    }
    
    @IBAction func leaderboardAction(_ sender: Any) {
        if isNetworkAvailable() && GKLocalPlayer.local.isAuthenticated{
            HAUtilities.playTapSound()
            let controller = GKGameCenterViewController.init()
            controller.gameCenterDelegate = self
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
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareAction(_ sender: Any) {
        // image to share
        let image = takeScreenshot(false)
        let imageToShare = [image!]
        // set up activity view controller
        
//        let url = URL(string: "google.com")
//        let shareText = "Your string goes here"
//        let shareItems: [Any] = [shareText, url!]
        
//        var imageToShare: [Any]!
//        let shareLink = HASettings.sharedInstance.applicationiTunesLink
//        let isValid = HAUtilities.isValidUrl(urlString: shareLink)
//        if isValid{
//            imageToShare = [image!, URL(string:shareLink!)!]
//        }
//        else{
//            imageToShare = [image!]
//        }
        
        
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // exclude some activity types from the list (optional)
        //activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.postToFacebook ]
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    open func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = screenshotImage, shouldSave {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        return screenshotImage
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = Bundle.main.loadNibNamed("HAScoreTableViewCell", owner: self, options: nil)?.first as! HAScoreTableViewCell
        return cell.frame.size.height
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("HAScoreTableViewCell", owner: self, options: nil)?.first as! HAScoreTableViewCell
        cell.selectionStyle = .none
        let category = categories[indexPath.row]
        cell.bgImageView.backgroundColor = UIColor.init(hexString: category.themeColorString!)
        cell.categoryNameLabel.text = category.name
        cell.pointsLabel.text = "\(dataManager.highscoreForCategory(category: category))"
        return cell
    }
    @IBAction func homeAction(_ sender: Any) {
        HAUtilities.playTapSound()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK:- Ad delegates
    /// Tells the delegate an ad request succeeded.
    /*func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        print("interstitialDidReceiveAd")
    }*/

    func showInterstitial() {
        if let ad = interstitial {
            ad.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
   
}
