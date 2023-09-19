//
//  HAMultiplayerMainViewController.swift
//  QuizApp Starter Kit All In One 1.0
//
//  Created by Satish Nerlekar on 07/09/18.
//  Copyright © 2018 Heavenapps. All rights reserved.
//

import UIKit
import GameKit

class HAMultiplayerMainViewController: UIViewController, HATurnbasedMatchHelperDelegate, GKGameCenterControllerDelegate, GKTurnBasedMatchmakerViewControllerDelegate {

    @IBOutlet weak var matchesButton: HACustomButton!
    @IBOutlet weak var playNowButton: HACustomButton!
    @IBOutlet weak var myWinsButton: HACustomButton!
    
    @IBOutlet var titleLabel: HACustomLabel!
    
    var matchesToPlayCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = titleLabel
        
        
        //using bigger icons for iPad
        if UIUserInterfaceIdiom.pad == UI_USER_INTERFACE_IDIOM(){
            playNowButton.setImage(#imageLiteral(resourceName: "challenge_button_icon_ipad"), for: .normal)
            matchesButton.setImage(#imageLiteral(resourceName: "getmore_icon_ipad"), for: .normal)
            myWinsButton.setImage(#imageLiteral(resourceName: "world_score_button_icon_ipad"), for: .normal)
        }

        
        playNowButton.isExclusiveTouch = true
        matchesButton.isExclusiveTouch = true
        
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if HATurnBasedMatchHelper.sharedInstance.takeAnotherChallenge{
            HATurnBasedMatchHelper.sharedInstance.takeAnotherChallenge = false
            //start new match
            HATurnBasedMatchHelper.sharedInstance.findMatch(minPlayers: 2, maxPlayers: 2, forCategory:nil , showExistingMatches: false, presentOnViewController: self) //pass category as nil to pic last played match
        }
        else{
            self.matchesToPlayCount = 0
            self.matchesButton.setTitle("Matches", for: .normal)//*****
            GKTurnBasedMatch.loadMatches { (ms, error) in
                if error != nil{
                    
                }
                else{
                    guard let matches = ms else{
                        return
                    }
                    
                    for match in matches{
                        if match.currentParticipant?.player.playerID == GKLocalPlayer.local.playerID
                        {
                            self.matchesToPlayCount += 1
                        }
                    }
                    if self.matchesToPlayCount > 0{
                        let title =  (self.matchesButton.titleLabel?.text)! + " (\(self.matchesToPlayCount))"
                        self.matchesButton.setTitle(title, for: .normal)
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func playNowAction(_ sender: Any) {
        HAUtilities.playTapSound()        
        if self.isNetworkAvailable()
        {
            print("Reachable via WiFi & Cellular")
            HATurnBasedMatchHelper.sharedInstance.delegate = self
            let controller = HACategoriesViewController.init(nibName: "HACategoriesViewController", bundle: nil)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func matchesAction(_ sender: Any) {
        HAUtilities.playTapSound()
        HATurnBasedMatchHelper.sharedInstance.delegate = self
        
        GKTurnBasedMatch.loadMatches { (matches, error) in
            if matches == nil{
                let alertController = UIAlertController(title: "Alert", message: "You have not played any matches yet.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default) { (alert) in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                let request = GKMatchRequest.init()
                request.minPlayers = 0
                request.maxPlayers = 0
                request.recipients = nil
                
                request.defaultNumberOfPlayers = 0;
                let controller = GKTurnBasedMatchmakerViewController.init(matchRequest: request)
                controller.showExistingMatches = true
                controller.turnBasedMatchmakerDelegate = self
                HATurnBasedMatchHelper.sharedInstance.presentingViewController = controller
                self.present(controller, animated: true) {
                }
            }
        }
    }
    
    
    @IBAction func myWinsAction(_ sender: Any) {
        if isNetworkAvailable() && GKLocalPlayer.local.isAuthenticated{
            HAUtilities.playTapSound()
            let controller = GKGameCenterViewController.init()
            controller.gameCenterDelegate = self
            controller.viewState = .leaderboards
            controller.leaderboardIdentifier = HASettings.sharedInstance.totalWinsLeaderboardID
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

    
    public func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController){
        viewController.dismiss(animated: true) {
        }
    }
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        let alertController = UIAlertController(title: "Oops", message: "Error while displaying matches, please try again later.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (alert) in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true) {
        }
    }

    
    //MARK:- HATurnBasedMatchHelperDelegate
    func enterNewGame(match: GKTurnBasedMatch)
    {
        hideActivity()
        let controller = HAGameViewController.init(nibName: "HAGameViewController", bundle: nil)
        self.navigationController?.navigationBar.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            self.navigationController?.navigationBar.alpha = 1.0
        }
        self.navigationController?.pushViewController(controller, animated: true)

    }
    
    func takeTurn(match: GKTurnBasedMatch) {
        hideActivity()
        
        let turnBasedHelper = HATurnBasedMatchHelper.sharedInstance
        turnBasedHelper.isMultiplayerGame = true
        
        if match.matchData?.count == 0{
            return
        }
        else{
            turnBasedHelper.saveToLoseList = true
        }
        
        let matchDict = turnBasedHelper.dictionayFromMatchData(matchData: match.matchData!)
        
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleVersion"] as AnyObject
        let currentVersion = nsObject as! String
        let appVersion = matchDict["v"] as! String
        
        if currentVersion.compare(appVersion, options: .numeric) == .orderedSame {
            print("store version is newer")
        }
        else{
            if currentVersion.compare(appVersion, options: .numeric) == .orderedDescending //isNewer
            {
                
            }
            else{
                let alertController = UIAlertController(title: "", message: "To accept this match, update your app to latest version", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
                    let appURLString = HASettings.sharedInstance.applicationiTunesLink!
                    
                    if let url = URL(string: appURLString) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
                alertController.addAction(okAction)
                alertController.addAction(updateAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
        
        
        if matchDict["category"] == nil {
            let alertController = UIAlertController(title: "Oops!", message: "There is some issue with game data. Please ignore this match", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
            return
        }
        
                        
        let controller = HAGameViewController.init(nibName: "HAGameViewController", bundle: nil)
        controller.multiplayerMatchDict = matchDict
        self.navigationController?.navigationBar.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            self.navigationController?.navigationBar.alpha = 1.0
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func layout(match: GKTurnBasedMatch) {
        hideActivity()
        if match.status == .ended
        {
            let controller = HATurnedBasedFinalViewController.init(nibName: "HATurnedBasedFinalViewController", bundle: nil)
            controller.match = match
            controller.pushedFromGC = true
            let navController = UINavigationController.init(rootViewController: controller)
            self.present(navController, animated: true)
        }
        else{
            let playerNum = (match.participants.index(of: match.currentParticipant!))! + 1
            let alertController = UIAlertController(title: "Status!", message: "Waiting for Player \(playerNum)'s turn", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
    }
}
