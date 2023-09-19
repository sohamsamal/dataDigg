//
//  HATurnBasedMatchHelper.swift
//  QuizApp Starter Kit All In One 1.0
//
//  Created by Satish Nerlekar on 16/05/18.
//  Copyright © 2018 Heavenapps. All rights reserved.
//

import Foundation
import GameKit

let kMyWins = "MyWins"
let kMyWinsPending = "MyWinsPending"
let kPreviousLocalPlayerID = "previousLocalPlayerID"
let kMatchID = "matchID"
let kScore = "score"

let kMatchIDsPlist = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/matchIDs.plist"
let kLoseMatchIDsPlist = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/loose_matchIDs.plist"
let kFailedSubmissionMatchesPlist = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/failed_submission_matches.plist"



protocol HATurnbasedMatchHelperDelegate {
    func enterNewGame(match: GKTurnBasedMatch)
    func takeTurn(match: GKTurnBasedMatch)
    func layout(match: GKTurnBasedMatch)
}


class HATurnBasedMatchHelper : NSObject, GKTurnBasedMatchmakerViewControllerDelegate, GKLocalPlayerListener {
   
    let reachability = Reachability()!
    var saveToLoseList: Bool! = false
    var isMultiplayerGame : Bool! = false
    var currentMatch : GKTurnBasedMatch? = nil
    var selectedCategory: HACategory? = nil
    var delegate : HATurnbasedMatchHelperDelegate! = nil
    var presentingViewController : UIViewController!
    
    var myWins: Int64 = 0
    var pendingWins: Int64 = 0
    var takeAnotherChallenge: Bool! = false
    
    static let sharedInstance = HATurnBasedMatchHelper()
    private override init() {
        
        super.init()
        
        if UserDefaults.standard.object(forKey: kMyWinsPending) != nil
        {
            pendingWins = ((UserDefaults.standard.object(forKey: kMyWinsPending) as? NSNumber)?.int64Value)!
        }else{
            pendingWins = 0
        }
        
        if UserDefaults.standard.object(forKey: kMyWins) != nil
        {
            self.myWins = ((UserDefaults.standard.object(forKey: kMyWins) as? NSNumber)?.int64Value)!
        }else{
            self.myWins = 0
        }

        
        
        
        //declare this property where it won't go out of scope relative to your listener
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(authenticationChanged), name: NSNotification.Name(rawValue: "GKPlayerAuthenticationDidChangeNotificationName"), object: nil)
        
        
        

    }
    
    //for testing only
    func resetMatchesAndAchievements(){
        GKTurnBasedMatch.loadMatches { (ms, error) in
            guard let matches = ms else{
                return
            }
            
            for match in matches
            {
                match.remove(completionHandler: { (error) in
                    print("match removed")
                })
            }

        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi, .cellular:
            
            if HASettings.sharedInstance.isMultiplayerSupportEnabled && HASettings.sharedInstance.isGameCenterSupported && GKLocalPlayer.local.isAuthenticated{
                self.performUpdates()
            }
            print("Reachable via WiFi")
        case .none:
            print("Network not reachable")
        }
    }
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        
        if(localPlayer.isAuthenticated)
        {
            localPlayer.unregisterListener(self)
            localPlayer.register(self)
        }
        else{
            localPlayer.authenticateHandler = {(viewController, error) -> Void in
                if viewController != nil {
                    // Show the view controller to let the player log in to Game Center.
                    self.presentViewController(viewController: viewController!)
                }
                else if localPlayer.isAuthenticated {
                    // You can start using Game Center
                    GKLocalPlayer.local.register(self)
                    
                    //self.resetMatchesAndAchievements()
                }
                else {
                    // Don't use Game Center
                }
            }
        }
    }
    
    @objc func authenticationChanged()
    {
        print("authentication changed")
        if GKLocalPlayer.local.isAuthenticated {
            // You can start using Game Center
            GKLocalPlayer.local.register(self)
            self.performUpdates()
            //self.removeAllMatches()
            print("authenticated")

        }
    }
    
    func presentViewController(viewController : UIViewController){
        let rootViewConrtoller = rootViewController()
        self.presentingViewController = rootViewConrtoller
        rootViewConrtoller.present(viewController, animated: true) {
        }
    }
    
    func rootViewController() -> UIViewController{
        return (UIApplication.shared.keyWindow?.rootViewController)!
    }
    
    public func rematch(match: GKTurnBasedMatch!){
        match.rematch { (match, error) in
            if error != nil{
                let allertController = UIAlertController(title: "Oops", message: error?.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    
                })
                allertController.addAction(okAction)
                (UIApplication.shared.delegate as! AppDelegate).navigationController?.present(allertController, animated: true, completion: nil)
            }
            else{
                self.delegate.enterNewGame(match: match!)
            }
        }
    }

    
    public func findMatch(minPlayers: Int, maxPlayers: Int, forCategory:HACategory?, showExistingMatches: Bool, presentOnViewController: UIViewController)
    {
        //self.presentingViewController = self.presentingViewController()
        let request = GKMatchRequest.init()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        var groupID: Int!
        if forCategory == nil{ //new game from final turnbased game
            groupID = Int((selectedCategory?.id)!)
        }
        else{//new game from main screen
            groupID = Int((forCategory?.id)!)
        }
        request.playerGroup = groupID
        let controller = GKTurnBasedMatchmakerViewController.init(matchRequest: request)
        controller.turnBasedMatchmakerDelegate = self
        controller.showExistingMatches = showExistingMatches
        presentViewController(viewController: controller)
    }
    
    //MARK:- GKTurnBasedMatchmakerViewControllerDelegate
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- GKEventLister listeners
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        
    }
    
    func player(_ player: GKPlayer, matchEnded match: GKTurnBasedMatch) {
        self.currentMatch = match
    }
    
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        
        self.presentingViewController.dismiss(animated: true, completion: nil)
        self.currentMatch = match
        
        let firstParticipant = match.participants[0]
        
        if firstParticipant.lastTurnDate == nil
        {
            delegate.enterNewGame(match: match)
        }
        else{
            var statusString : String? = nil
            var thisParticipant : GKTurnBasedParticipant? = nil
            var otherParticipant : GKTurnBasedParticipant? = nil
            
            for participant in match.participants
            {
                if participant.player.playerID == GKLocalPlayer.local.playerID
                {
                    thisParticipant = participant
                }
                else{
                    otherParticipant = participant
                }
            }
            if thisParticipant?.matchOutcome == .quit {

                statusString = "You have Quit this match"
            }
            else if otherParticipant?.matchOutcome == .quit
            {
                statusString = "Opponent has Quit this match"
            }
            else if otherParticipant?.status ==  .declined
            {
                statusString = "Opponent has Declined your challenge"
            }

            if statusString == nil{
                if match.currentParticipant?.player.playerID == GKLocalPlayer.local.playerID
                {
                    delegate.takeTurn(match: match)
                }
                else{
                    delegate.layout(match: match)
                }
            }
            else{
                let alertController = UIAlertController(title: "Match status\n", message:statusString , preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                    
                }
                alertController.addAction(okAction)
                self.presentingViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func player(_ player: GKPlayer, didRequestMatchWithRecipients recipientPlayers: [GKPlayer]) {
        
    }
    
    func player(_ player: GKPlayer, didRequestMatchWithOtherPlayers playersToInvite: [GKPlayer]) {
        
        print("didRequestMatchWithOtherPlayers")
        self.presentingViewController.dismiss(animated: true, completion: nil)

        let request = GKMatchRequest.init()
        request.minPlayers = 2
        request.maxPlayers = 2
        request.recipients = playersToInvite
        let controller = GKTurnBasedMatchmakerViewController.init(matchRequest: request)
        controller.showExistingMatches = false
        controller.turnBasedMatchmakerDelegate = self
        presentViewController(viewController: controller)
    }
    
    func player(_ player: GKPlayer, wantsToQuitMatch match: GKTurnBasedMatch) {
        self.currentMatch = match
    }
    
    //MARK:- Achievement
    func achievementsFor(wins: Int64, forPlayer:GKPlayer) -> GKAchievement?{
        
        let achievementIDs = HASettings.sharedInstance.achievementsForWins
        var achievementID: String? = nil
        
        for achievementDict in achievementIDs!{
            if wins >= (((achievementDict as Dictionary)["Wins"] as! NSNumber)).int64Value
            {
                achievementID = (achievementDict as! Dictionary)["Achievement ID"]
            }
        }
        guard let unwrappedAchievementID = achievementID else{
            return nil
        }
        
        let achievement = GKAchievement.init(identifier: unwrappedAchievementID, player: forPlayer)
        achievement.percentComplete = 100.0
        return achievement
    }
    
   
    
    
    //MARK:- Cheat handling methods
    func checkForFraudMatchesAndSubmitAsLost()
    {
        guard let matchIDs = NSArray.init(contentsOfFile: kLoseMatchIDsPlist) else {
            return
        }
        
        for matchID in matchIDs{
            GKTurnBasedMatch.load(withID: matchID as! String) { (match, error) in
                if error != nil{
                    
                }
                else if match == nil{
                    self.removeMatchIDMarkedAsLost(matchID: match?.matchID)
                }
                else{
                    var localPlayer: GKTurnBasedParticipant?
                    var otherPlayer: GKTurnBasedParticipant?
                    
                    for participant in (match?.participants)!
                    {
                        if participant.player.playerID == GKLocalPlayer.local.playerID{
                            localPlayer = participant
                        }
                        else{
                            otherPlayer = participant
                        }
                    }
                    
                    localPlayer?.matchOutcome = .lost
                    otherPlayer?.matchOutcome = .won
                    
                    match?.endMatchInTurn(withMatch: (match?.matchData)!, completionHandler: { (error) in
                        if error != nil{
                            if error?.code == 24{
                                self.removeMatchIDMarkedAsLost(matchID: match?.matchID)
                            }
                        }
                        else{
                            self.removeMatchIDMarkedAsLost(matchID: match?.matchID)
                        }
                    })
                }
            }
        }
    }
        
    func removeInvalidMatchesWithoutMatchData(){
        GKTurnBasedMatch.loadMatches { (ms, error) in
            guard let matches = ms else{
                return
            }
            
            for match in matches{
                if match.matchData?.count == 0{
                   match.remove(completionHandler: nil)
                }
            }
        }
    }
    
    func checkForResubmissionOfMatches(){
        
        let matches = NSArray.init(contentsOfFile: kFailedSubmissionMatchesPlist)
        
        guard let unwrappedMatches = matches else {
            return
        }
        
        for faileMatchDict in unwrappedMatches{
            let matchID = (faileMatchDict as! Dictionary<String,AnyObject>)[kMatchID] as! String
            GKTurnBasedMatch.load(withID: matchID) { (match, error) in
                if error != nil{
                    if error?.code == 24{
                        self.removeFromResubmittedList(matchID: matchID)
                    }
                }
                else if match == nil{
                    
                }
                else{
                    let myScore = ((faileMatchDict as! Dictionary<String,AnyObject>)[kScore] as! NSNumber).int64Value
                    var player1: GKTurnBasedParticipant!
                    var player2: GKTurnBasedParticipant!
                    
                    for participant in (match?.participants)!{
                        if participant.player.playerID == GKLocalPlayer.local.playerID{
                            player1 = participant
                        }
                        else{
                            player2 = participant
                        }
                    }
                    
                    let data = self.updateMatchDataWithPoints(matchData: (match?.matchData)!, points: myScore, playerID: (match?.currentParticipant?.player.playerID)!)
                    let quizDict = self.dictionayFromMatchData(matchData: (match?.matchData)!)
                    
                    let otherScore = (quizDict["\(String(describing: player2.player.playerID))_points"] as! NSNumber).int64Value
                    
                    if myScore < otherScore{
                        player1.matchOutcome = .lost
                        player2.matchOutcome = .won
                    }
                    else if myScore == otherScore{
                        player1.matchOutcome = .tied
                        player2.matchOutcome = .tied
                    }
                    else{
                        self.iWon()
                        player1.matchOutcome = .won
                        player2.matchOutcome = .lost
                    }
                    
                    match?.endMatchInTurn(withMatch: data, scores: [], achievements: [], completionHandler: { (error) in
                        if error != nil{
                            if error?.code == 24 //invalid match state
                            {
                                self.removeFromResubmittedList(matchID: match?.matchID)
                            }
                        }
                        else{
                            self.removeFromResubmittedList(matchID: match?.matchID)
                        }
                    })
                }
            }
        }
}

    
    func removeMatchIDMarkedAsLost(matchID: String!)
    {
        guard let matchIDs = NSMutableArray.init(contentsOfFile: kLoseMatchIDsPlist) else{
            return
        }
        
        if (matchIDs.contains(matchID)){
            matchIDs.remove(matchID)
            matchIDs.write(toFile: kLoseMatchIDsPlist, atomically: true)
        }
    }
    
    public func saveCurrentMatchInLoseList(){
        var matchIDs = NSMutableArray.init(contentsOfFile: kLoseMatchIDsPlist)
        if matchIDs == nil || matchIDs?.count == 0 {
            matchIDs = NSMutableArray.init()
            matchIDs?.add(self.currentMatch?.matchID as Any)
        }
        matchIDs?.write(toFile: kLoseMatchIDsPlist, atomically: true)
    }
    
    func iWon(){
        //iWon block start
        
        if GKLocalPlayer.local.isAuthenticated == false{
            self.pendingWins = self.pendingWins + 1
            UserDefaults.standard.set(NSNumber(value: self.pendingWins), forKey: kMyWinsPending)
            UserDefaults.standard.synchronize()
            print("Win stored locally")
        }
        else{
            
            if HASettings.sharedInstance.totalWinsLeaderboardID != nil{
                let score = GKScore.init(leaderboardIdentifier: HASettings.sharedInstance.totalWinsLeaderboardID!)
                if self.pendingWins > 0{
                    score.value = self.myWins + 1 + self.pendingWins
                }
                else{
                    score.value = self.myWins + 1
                }
                
                GKScore.report([score], withCompletionHandler: { (error) in
                    if error != nil{
                        self.pendingWins = self.pendingWins + 1
                    }
                    else{
                        self.pendingWins = 0
                        self.myWins = self.myWins + 1
                        UserDefaults.standard.set(NSNumber(value: self.pendingWins), forKey: kMyWinsPending)
                        UserDefaults.standard.set(NSNumber(value: self.myWins), forKey: kMyWins)
                        UserDefaults.standard.synchronize()
                        self.updateAchievements()
                        print("Win updated")
                    }
                })
            } //if HASettings.sharedInstance.totalWinsLeaderboardID != nil block
        }//iWon block end
    }
    
    func updateAchievements(){
        
        guard let achievements = HASettings.sharedInstance.achievementsForWins else{
            return
        }
        
        var firstAchievementDict: Dictionary<String, AnyObject>!
        var postAchivements = [GKAchievement]()
        
        if achievements.count > 0
        {
            firstAchievementDict = achievements[0] as Dictionary<String, AnyObject>
        }
        
        for achievementDict in achievements {
            let requiredPoints = ((achievementDict as Dictionary<String,AnyObject>)[kWins]! as! NSNumber).intValue
            let firstAchievementWins = ((firstAchievementDict as Dictionary<String,AnyObject>)[kWins]! as! NSNumber).intValue

            if self.myWins >= requiredPoints && self.myWins >= firstAchievementWins{
                let achievementID = ((achievementDict as Dictionary<String,AnyObject>)[kAchievementID]! as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                let achievement = GKAchievement.init(identifier:achievementID)
                achievement.percentComplete = 100.0
                postAchivements.append(achievement)
            }
        }
        
        if postAchivements.count > 0{
            GKAchievement.report(postAchivements) { (error) in
                if error != nil{
                    
                }
                else{
                    print("Achievement posted")
                }
            }
        }
    }
    
    func reportPendingWins() {
        
        if self.pendingWins > 0{
            
            guard let totalWinsLeaderboard = HASettings.sharedInstance.totalWinsLeaderboardID else{
                return
            }
            
            let score = GKScore.init(leaderboardIdentifier: totalWinsLeaderboard)
            score.value = self.myWins + self.pendingWins
            GKScore.report([score]) { (error) in
                if error != nil{
                    print("Error in posting wins, will try later")
                }else{
                    self.pendingWins = 0
                    self.myWins += 1
                    UserDefaults.standard.set(NSNumber(value: self.myWins), forKey: kMyWins)
                    UserDefaults.standard.set(NSNumber(value: self.pendingWins), forKey: kMyWinsPending)
                    UserDefaults.standard.synchronize()
                    
                    self.updateAchievements()
                }
            }
        }
    }
    
    func checkForPendingMatchesForWins(){
        guard let matchIDs = NSMutableArray.init(contentsOfFile: kMatchIDsPlist) else{
            return
        }
        for mID in matchIDs
        {
            let matchID = mID as! String
            GKTurnBasedMatch.load(withID: matchID) { (match, error) in
                if error != nil{
                    print("unable to fetch match ID \(matchID)")
                }
                else if match == nil{
                    self.removeMatchID(id:matchID)
                }else{
                    let participants = match?.participants
                    var localPlayer: GKTurnBasedParticipant? = nil
                    for participant in participants!
                    {
                        
                        if participant.player.playerID == GKLocalPlayer.local.playerID{
                            localPlayer = participant
                            break
                        }
                    }
                    
                    if localPlayer?.matchOutcome == .won{
                        self.pendingWins += 1
                        UserDefaults.standard.set(NSNumber(value: self.pendingWins), forKey: kMyWinsPending)
                        UserDefaults.standard.synchronize()
                        self.removeMatchID(id: matchID)
                        self.reportPendingWins()
                        print("Won match id \(String(describing: match?.matchID)) removed")
                    }
                    else if localPlayer?.matchOutcome == .lost || localPlayer?.matchOutcome == .tied || localPlayer?.matchOutcome == .quit || localPlayer?.matchOutcome == .timeExpired{
                        self.removeMatchID(id: matchID)
                        print("tied match id \(String(describing: match?.matchID)) removed")
                    }
                }
            }
        }
    }
    
    func updateMyWinsCountFromLeaderboard()
    {
        guard let totalWinsLBID = HASettings.sharedInstance.totalWinsLeaderboardID else{
            return
        }
        
        let leaderboardRequest = GKLeaderboard.init(players: [GKLocalPlayer.local])
        leaderboardRequest.timeScope = .allTime
        leaderboardRequest.playerScope = .global
        leaderboardRequest.identifier = totalWinsLBID
        
        leaderboardRequest.loadScores { (ss, error) in
            if error != nil{
                
            }
            guard let scores = ss else{
                return
            }
            if scores.count > 0{
                let score = scores[0]
                if score.value > self.myWins{
                    self.myWins = score.value
                    UserDefaults.standard.set(NSNumber(value: self.myWins), forKey: kMyWins)
                    UserDefaults.standard.synchronize()
                    print("updated wins : \(self.myWins)")
                }
            }
        }
    }

    //MARK:- Data packing methods
    func updateMatchDataWithPoints(matchData: Data, points:Int64, playerID: String) -> Data
    {
        let newString = String.init(data: matchData, encoding: .utf8)!
        var dictonary:NSDictionary?
        var newMatchData: Data!
        if let data = newString.data(using: String.Encoding.utf8) {
            do {
                dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                let key = "\(playerID)_points"
                let quizDict = dictonary?.mutableCopy() as? NSMutableDictionary
                quizDict![key] = NSNumber(value: points)
                newMatchData = try JSONSerialization.data(withJSONObject: quizDict!, options: .prettyPrinted)
                // here "jsonData" is the dictionary encoded in JSON data
                
            } catch let error as NSError {
               print(error.localizedDescription)
            }
        }
        return newMatchData
    }
    
    func dataForMultiplayer(category: HACategory, questions:[HAQuestion], points:Int64, playerID: String) -> Data{
        var dataPack:NSMutableDictionary!
        var newMatchData: Data!
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleVersion"] as AnyObject
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String


        dataPack = NSMutableDictionary.init()
        dataPack.setValue(category.dictionary(), forKey: "category")

        let questionsArray = NSMutableArray.init()
        for question in questions{
            questionsArray.add(question.dictionary())
        }
        dataPack.setValue(questionsArray, forKey: "Questions")
        

        dataPack.setValue(NSNumber(value: points), forKey: "\(playerID)_points")
        dataPack.setValue(version, forKey: "v")
        
        do{
            newMatchData = try JSONSerialization.data(withJSONObject: dataPack, options: .prettyPrinted)
        }
        catch let error as NSError {
             print(error.localizedDescription)
        }
        return newMatchData
    }
    
    func dictionayFromMatchData(matchData: Data) -> NSDictionary{
        let newString = String.init(data: matchData, encoding: .utf8)!
        var matchDictionay:NSMutableDictionary!
        if let data = newString.data(using: String.Encoding.utf8) {
            do {
                let dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                matchDictionay = (dictonary?.mutableCopy() as! NSMutableDictionary)
                
                //converting questions back to object. Every project has some dirty code to support previous versions :)
                let questions = matchDictionay["Questions"] as! NSArray
                let questionArray = NSMutableArray.init()
                for questionDict in questions
                {
                    let question = HAQuestion.init()
                    questionArray.add(question.questionObject(fromDictionary: questionDict as! NSDictionary))
                }
                matchDictionay["Questions"] = questionArray
                
                //converting category dict back to object.
                let categoryDict = matchDictionay["category"]
                let category = HACategory.init()
                matchDictionay["category"] = category.categoryObject(fromCategoryDict: categoryDict as! NSDictionary)
            
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return matchDictionay
    }
    
    //MARK:- Resubmission methods & fraud
    func saveCurrentMatchInResubmissionList(withScore: Int64)
    {
        
        var matches = NSMutableArray.init(contentsOfFile: kFailedSubmissionMatchesPlist)
        if matches == nil
        {
            matches = NSMutableArray.init()
        }
        
        let savedMatch = NSMutableDictionary.init()
        savedMatch.setValue(self.currentMatch?.matchID , forKey: kMatchID)
        savedMatch.setValue(NSNumber(value: withScore) , forKey: kScore)
        matches?.add(savedMatch)
        matches?.write(toFile:kFailedSubmissionMatchesPlist , atomically: true)
    }
    
    func removeFromResubmittedList(matchID: String!){
        let matches = NSMutableArray.init(contentsOfFile: kFailedSubmissionMatchesPlist)
        for matchDict in matches! {
            if (matchDict as! Dictionary)[kMatchID]  == matchID
            {
                matches?.remove(matchID)
                matches?.write(toFile: kFailedSubmissionMatchesPlist, atomically: true)
                break
            }
        }
    }
    
    func addMatchID(id: String!)
    {
        var matchIDs = NSMutableArray.init(contentsOfFile: kMatchIDsPlist)
        if matchIDs == nil{
            matchIDs = NSMutableArray.init()
            matchIDs?.add(id)
        }
        else{
            matchIDs?.add(id)
        }
        matchIDs?.write(toFile: kMatchIDsPlist, atomically: true)
    }
    
    func removeMatchID(id: String!)
    {
        let matchIDs = NSMutableArray.init(contentsOfFile: kMatchIDsPlist)
        if matchIDs != nil{
            matchIDs?.remove(id)
            matchIDs?.write(toFile: kMatchIDsPlist, atomically: true)
        }
    }
    
    
    func resetLocalPlayerData() -> Bool
    {
        let previousPlayerID = UserDefaults.standard.object(forKey: kPreviousLocalPlayerID) as? String
        
        if (GKLocalPlayer.local.playerID != previousPlayerID && HASettings.sharedInstance.isMultiplayerSupportEnabled)
        {
            UserDefaults.standard.set(GKLocalPlayer.local.playerID, forKey:kPreviousLocalPlayerID)
            pendingWins = 0
            myWins = 0
            UserDefaults.standard.set(NSNumber(value: myWins), forKey: kMyWins)
            UserDefaults.standard.set(NSNumber(value: pendingWins), forKey: kMyWinsPending)
            UserDefaults.standard.synchronize()

            if FileManager.default.fileExists(atPath: kMatchIDsPlist){
                do{
                    try FileManager.default.removeItem(atPath: kMatchIDsPlist)
                }catch{
                }
            }
            
            
            if FileManager.default.fileExists(atPath: kFailedSubmissionMatchesPlist){
                do{
                    try FileManager.default.removeItem(atPath: kFailedSubmissionMatchesPlist)
                }catch{
                }
            }

            
            if FileManager.default.fileExists(atPath: kFailedSubmissionMatchesPlist){
                do{
                    try FileManager.default.removeItem(atPath: kFailedSubmissionMatchesPlist)
                }catch{
                }
            }

            return true
        }
        
        return false
    }
    
    func performUpdates(){
        
        let reset = resetLocalPlayerData()
        
        if reset == false{
            removeInvalidMatchesWithoutMatchData()
            checkForFraudMatchesAndSubmitAsLost()
            checkForResubmissionOfMatches()
            checkForPendingMatchesForWins()
            updateMyWinsCountFromLeaderboard()
        }
    }
}








