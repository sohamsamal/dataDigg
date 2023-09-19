//
//  HASettings.swift
//  Quiz App Starter Kit All In One 1.0
//
//

import Foundation
import GoogleMobileAds

let InterfaceSettings = "Interface Settings"
let BoldAppFont = "Bold App Font"
let NonBoldAppFont = "Non Bold App Font"
let BoldTextInHEX = "Bold Text Color In HEX"
let NonBoldTextColorInHEX = "Non Bold Text Color In HEX"
let MenuScreenTitle = "Menu Screen Title"
let CategoriesScreenTitle = "Categories Screen Title"
let AboutScreenTitle = "About Screen Title"
let AboutTextOrURL = "About Text Or URL"
let AppTextColor = "App Text Color"

let FeaturesSettings = "Features Settings"
let EnableAdsSupport = "Enable Ads Support"
let RemoveAdsProductIdentifier = "Remove Ads Product Identifier"
let EnableGameCenter = "Enable Game Center"
let EnableInAppPurchase = "Enable In App Purchase"
let DataInputFormat = "Data Input Format"
let EnableShuffleQuestions = "Enable Shuffle Questions"
let EnableShuffleAnswers = "Enable Shuffle Answers"
let HighlighCorrectAnswerIfansweredWrong = "Highlight Correct Answer If answered Wrong"
let EnableTimerBasedScore = "Enable Timer Based Score"
let EnableParentalGate = "Enable Parental Gate"
let ApplicationiTunesLink = "ApplicationiTunesLink"
let FullPointsBeforeSeconds = "Full Points Before Seconds"
let EnableMultiplayerSupport = "Enable Multiplayer Support"
let TotalWinsLeaderboardID = "Total Wins Leaderboard ID"
let AchievementsForWins = "Achievements For Wins"


let kSoundsOnOff = "SoundsOnOff"
let kAdsTurnedOff = "AdsTurnedOff"
let kShowExplanation = "ShowExplanation"
let kAchievementID = "Achievement ID"
let kWins = "Wins"

let kConfigurationFilePath = "\(Bundle.main.bundlePath + "/Configuration.plist")"



final class HASettings{
    
    static let sharedInstance = HASettings()
    
    public var isAdSupported = false
    public var isGameCenterSupported = false
    public var isInAppPurchaseSupported  = false
    public var isShuffleAnswersEnabled = false
    public var isShuffleQuestionsEnabled = false
    public var isHighlightCorrectAnswerEnabled = true
    public var isTimerbasedScoreEnabled = false
    public var isParentalGateEnabled = false
    public var removeAdsProdcutIdentifier : String? = nil
    public var dataInputFormat : String = "plist"
    public var applicationiTunesLink : String? = nil
    public var fullPointsBeforeSeconds : Int = 0
    public var totalWinsLeaderboardID : String? = nil
    public var isMultiplayerSupportEnabled = false
    public var achievementsForWins : [Dictionary<String,AnyObject>]? = nil
    
    
    public var menuScreenTittle : String = ""
    public var categoriesScreenTitle : String = ""
    public var aboutScreenTitle : String = ""
    public var aboutScreenTextOrURL : String = ""
    public var appTextColor : String = ""
    
    
    public var isSoundsOn : Bool = false
    private var isAdsTurnedOff : Bool = false
    public var showExplanation : Bool = false
    public var isGameScreenVisible : Bool = false
    public var isMultiplayerGame : Bool = false
    
    private init() {
        print(kConfigurationFilePath)
        
       if let configurationDict = NSDictionary(contentsOfFile: kConfigurationFilePath)  as? Dictionary<String, AnyObject>
       {
            if let featuresSettings = configurationDict[FeaturesSettings]
            {
                isAdSupported = featuresSettings[EnableAdsSupport] as! Bool
                
                isGameCenterSupported = featuresSettings[EnableGameCenter] as! Bool
                isInAppPurchaseSupported = featuresSettings[EnableInAppPurchase] as! Bool
                isShuffleAnswersEnabled = featuresSettings[EnableShuffleAnswers] as! Bool
                isShuffleQuestionsEnabled = featuresSettings[EnableShuffleQuestions] as! Bool
                isHighlightCorrectAnswerEnabled = featuresSettings[HighlighCorrectAnswerIfansweredWrong] as! Bool
                isParentalGateEnabled =  featuresSettings[EnableParentalGate] as! Bool
                isTimerbasedScoreEnabled =  featuresSettings[EnableTimerBasedScore] as! Bool
                removeAdsProdcutIdentifier = (featuresSettings[RemoveAdsProductIdentifier] as! String)
                dataInputFormat = featuresSettings[DataInputFormat] as! String
                
                applicationiTunesLink = featuresSettings[ApplicationiTunesLink] as? String
                
                fullPointsBeforeSeconds = featuresSettings[FullPointsBeforeSeconds] as! Int
                isMultiplayerSupportEnabled = featuresSettings[EnableMultiplayerSupport] as! Bool
                totalWinsLeaderboardID = featuresSettings[TotalWinsLeaderboardID] as? String
                achievementsForWins = (featuresSettings[AchievementsForWins] as? [Dictionary<String,AnyObject>])
                
                print("Featires settings : \(featuresSettings)")
                
              
                //Default values
                if UserDefaults.standard.value(forKey: kSoundsOnOff) == nil
                {
                   UserDefaults.standard.set(true, forKey: kSoundsOnOff)
                   UserDefaults.standard.synchronize()
                    isSoundsOn = true
                }else{
                    isSoundsOn = UserDefaults.standard.object(forKey: kSoundsOnOff) as! Bool
                }
                
                if UserDefaults.standard.value(forKey: kShowExplanation) == nil
                {
                    UserDefaults.standard.set(true, forKey: kShowExplanation)
                    UserDefaults.standard.synchronize()
                    showExplanation = true
                }else{
                    showExplanation = UserDefaults.standard.object(forKey: kShowExplanation) as! Bool
                }

                if isAdSupported == true{
                    if UserDefaults.standard.value(forKey: kAdsTurnedOff) == nil
                    {
                        UserDefaults.standard.set(false, forKey: kAdsTurnedOff)
                        UserDefaults.standard.synchronize()
                        isAdsTurnedOff = false
                    }else{
                        isAdsTurnedOff = UserDefaults.standard.object(forKey: kAdsTurnedOff) as! Bool
                    }
                }
                
            }
        
            if let interfaceSettings = configurationDict[InterfaceSettings]
            {
                menuScreenTittle = interfaceSettings[MenuScreenTitle] as! String
                categoriesScreenTitle = interfaceSettings[CategoriesScreenTitle] as! String
                aboutScreenTitle = interfaceSettings[AboutScreenTitle] as! String
                aboutScreenTextOrURL = interfaceSettings[AboutTextOrURL] as! String
                appTextColor = interfaceSettings[AppTextColor] as! String
            }
        }
    }
    
    public func requireAdsDisplay() -> Bool{
        return true
        if(isAdSupported)
        {
            print("IS ADS TURNED OFF \(isAdsTurnedOff)")
            return isAdsTurnedOff
        }
        return false
    }
    
    public func removeAdsEnabled() -> Bool{
        if removeAdsProdcutIdentifier != nil && requireAdsDisplay(){
            return true
        }
        return false
    }
    
   public func setSoundEnabled(sound: Bool) -> Void
    {
        UserDefaults.standard.set(sound, forKey: kSoundsOnOff)
        UserDefaults.standard.synchronize()
        isSoundsOn = sound
    }
    
   public func setAdsTurnedOff(show: Bool) -> Void{
        UserDefaults.standard.set(show, forKey: kAdsTurnedOff)
        UserDefaults.standard.synchronize()
        isAdsTurnedOff = show
    }
    
    public func setShowExplanation(show: Bool) -> Void {
        UserDefaults.standard.set(show, forKey: kShowExplanation)
        UserDefaults.standard.synchronize()
        showExplanation = show
    }
    
    func isProductPurchased(productIdentifier: String?) -> Bool
    {
        if productIdentifier == nil || productIdentifier == ""{
            return true
        }
        else
        {
            if UserDefaults.standard.value(forKey: productIdentifier!) != nil
            {
                return true
            }
            return false
        }
    }
    
    public func showAdmobBannerAd(for bannerView: GADBannerView, onController: UIViewController!){
        onController.view.addSubview(bannerView)
        bannerView.adUnitID = kAdmobBannerAdUnitID
        bannerView.rootViewController = onController
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.bottomAnchor.constraint(equalTo: onController.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: onController.view.centerXAnchor).isActive = true
        let request = GADRequest()
      //request.testDevices = [kAdmobTestDevice] //**** Remove this line of code while uploading to store, if ads enabled in app.
        bannerView.load(request)
    }
    
}
