//
//  HATurnedBasedFinalViewController.swift
//  QuizApp Starter Kit All In One 1.0
//
//  Created by Satish Nerlekar on 23/05/18.
//  Copyright © 2018 Heavenapps. All rights reserved.
//

import UIKit
import GameKit
import StoreKit
import GoogleMobileAds


class HATurnedBasedFinalViewController: UIViewController, GKGameCenterControllerDelegate, GADInterstitialDelegate {
    @IBOutlet var titleView: HACustomLabel!
    @IBOutlet weak var statusLabel: HACustomLabel!
    @IBOutlet weak var myScoreLabel: HACustomLabel!
    @IBOutlet weak var cupImageView: UIImageView!
    
    @IBOutlet weak var opponentScoreLabel: HACustomLabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var leaderboardsButton: UIButton!
    @IBOutlet weak var rematchButton: UIButton!
    @IBOutlet weak var newMatchButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    var interstitial: GADInterstitial!

    
    @IBOutlet weak var rematchStackViewHeightConstraint: NSLayoutConstraint!
    var pushedFromGC: Bool! = false
    var match: GKTurnBasedMatch! = nil
    var selectedCategory: HACategory!
    
    @IBOutlet weak var rematchStackView: UIStackView!
    
    @IBAction func homeAction(_ sender: Any) {
        HAUtilities.playTapSound()

        self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
        self.navigationController?.popToRootViewController(animated: true)

        if pushedFromGC{
            self.dismiss(animated: true)
        }
        else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if pushedFromGC{
            //remove rematch & new game when launched from game screen, reason is user can try to play old game and category may not be existed on CMS.
            rematchButton.isHidden = true
            newMatchButton.isHidden = true
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: homeButton)
        
            let matchDict = HATurnBasedMatchHelper.sharedInstance.dictionayFromMatchData(matchData: match.matchData!)
        let category = matchDict["category"] as! HACategory
        self.selectedCategory = category
        self.navigationItem.titleView = titleView
        titleView.text = category.name
            let categoryColor = UIColor(hexString: category.themeColorString!)
            self.view.backgroundColor = categoryColor
            
            var thisParticipant : GKTurnBasedParticipant? = nil
            var otherParticipant : GKTurnBasedParticipant? = nil
            
            for participant in (match.participants)
            {
                if participant.player.playerID == GKLocalPlayer.local.playerID
                {
                    thisParticipant = participant
                }
                else{
                    otherParticipant = participant
                }
            }
            
            if thisParticipant?.matchOutcome == .quit
            {
                
            }
            else if otherParticipant?.matchOutcome == .quit
            {
                
            }
            else{
                self.title = category.name
                let key = (thisParticipant?.player.playerID)! + "_points"
                let thisPlayerScore = (matchDict[key] as! NSNumber).int64Value
                
                if match.status != .ended
                {
                    rematchButton.isEnabled = false
                    statusLabel.text = "NOW ITS OPPONENT'S TURN!"
                    cupImageView.image = #imageLiteral(resourceName: "opponent")
                    myScoreLabel.text = "You scored : \(thisPlayerScore) points"
                    opponentScoreLabel.text = ""
                }
                else{
                    let key = (otherParticipant?.player.playerID)! + "_points"
                    let otherScore = (matchDict[key] as! NSNumber).int64Value
                    
                    myScoreLabel.text = "You scored : \(thisPlayerScore) points"
                    opponentScoreLabel.text = (otherParticipant?.player.alias)! + " has scored : \(otherScore) points"
                    
                    if thisPlayerScore < otherScore{
                        rematchButton.isEnabled = true
                        statusLabel.text = "YOU LOST!"
                        cupImageView.image = #imageLiteral(resourceName: "cup_lost")
                    }
                    else if thisPlayerScore > otherScore{
                        rematchButton.isEnabled = true
                        statusLabel.text = "YOU WON!"
                        cupImageView.image = #imageLiteral(resourceName: "cup_winner")
                    }
                    else{
                        rematchButton.isEnabled = true
                        statusLabel.text = "TIED!"
                        cupImageView.image = #imageLiteral(resourceName: "cup_tie")
                    }
                }
                
            }

        self.rematchButton.isHidden = true //hide initially
        GKLocalPlayer.local.loadRecentPlayers { (ps, error) in
            guard let players = ps else{
                return
            }
            var found = false
            for player in players{
                if otherParticipant?.player.playerID == player.playerID{
                    found = true
                    print("Recently played or found a friend")
                    break
                }
            }
            if found{
                self.rematchButton.isHidden = false
            }
        }
        
        
        if HASettings.sharedInstance.requireAdsDisplay(){
            interstitial = GADInterstitial(adUnitID: kAdmobFullScreenAdUnitID)
            interstitial.delegate = self
            let request = GADRequest()
            interstitial.load(request)
        }
        
        SKStoreReviewController.requestReview()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: selectedCategory.themeColorString!, alpha:1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
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
    
    @IBAction func rematchAction(_ sender: Any) {
        HAUtilities.playTapSound()
        if let viewController = navigationController?.viewControllers.first(where: {$0 is HAMultiplayerMainViewController}) {
            navigationController?.popToViewController(viewController, animated: false)
        }
        HATurnBasedMatchHelper.sharedInstance.rematch(match: match)
    }
    
    @IBAction func newMatchAction(_ sender: Any) {
        HAUtilities.playTapSound()
        HATurnBasedMatchHelper.sharedInstance.takeAnotherChallenge = true
        if let viewController = navigationController?.viewControllers.first(where: {$0 is HAMultiplayerMainViewController}) {
            navigationController?.popToViewController(viewController, animated: false)
        }
    }
    
    //MARK:- Ad delegates
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        print("interstitialDidReceiveAd")
    }
}
