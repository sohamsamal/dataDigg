//
//  HACategory.swift
//  Quiz App Starter Kit All In One 1.0
//
//

import Foundation

let kCategoryDescription = "category_description"
let kCategoryImagePath = "category_image_path"
let kCategoryTimerRequired = "timer_required"
let kCategoryQuestionsLimit = "category_questions_max_limit"
let kCategoryLeaderboardID = "leaderboard_id"
let kCategoryColor = "category_color"
let kCategoryID = "category_id"
let kCategoryName = "category_name"
let kCategoryProductIdentifier = "productIdentifier"
let kSubscriptions = "subscriptions"
let kRemainingSeconds = "remainingSeconds"


class HACategory{
    
    public var name : String!
    public var id : String!
    public var description : String?
    public var themeColorString : String?
    public var questionLimit : Int! = 0
    public var showTimer : Bool = true
    public var leaderboardID : String?
    public var iconFilename : String?
    public var categoryId: String?
    public var productIdentifier : String?
    
    public var subscriptions : [String]?
    public var remainingSeconds: String?
    
  /*  enum CodingKeys : String, CodingKey {
        case name = "category_name"
        case id = "category_id"
        case description = "category_description"
        case questionLimit = "category_questions_max_limit"
        case leaderboardID = "leaderboard_id"
        case iconFilename = "category_image_path"
        case productIdentifier = "productIdentifier"
        case showTimer = "timer_required"
        case themeColorString = "category_color"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(String.self, forKey: .id)
        
        let qLimit = try container.decode(String.self, forKey: .questionLimit)
        questionLimit = Int(qLimit)
        
        leaderboardID = try container.decode(String.self, forKey: .leaderboardID)
        description  = try container.decode(String.self, forKey: .description)
        iconFilename = try container.decode(String.self, forKey: .iconFilename)
        productIdentifier = try container.decode(String.self, forKey: .productIdentifier)
        showTimer = try container.decode(Bool.self, forKey: .showTimer)
        themeColorString = try container.decode(String.self, forKey: .themeColorString)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
        try container.encode("\(questionLimit!)", forKey: .questionLimit)
        
        try container.encode(leaderboardID, forKey: .leaderboardID)
        try container.encode(description, forKey: .description)
        try container.encode(iconFilename, forKey: .iconFilename)
        try container.encode(productIdentifier, forKey: .productIdentifier)
        try container.encode(showTimer, forKey: .showTimer)
        try container.encode(themeColorString, forKey: .themeColorString)

    }*/
    
    
    func dictionary() -> NSMutableDictionary
    {
        let categoryDict = NSMutableDictionary.init()
        categoryDict.setValue(self.name, forKey: kCategoryName)
        categoryDict.setValue(self.id, forKey: kCategoryID)
        categoryDict.setValue(self.description, forKey: kCategoryDescription)
        categoryDict.setValue(self.categoryId, forKey: kCategoryID)
        categoryDict.setValue(self.themeColorString, forKey: kCategoryColor)
        categoryDict.setValue("\(self.questionLimit!)", forKey: kCategoryQuestionsLimit)
        categoryDict.setValue(self.leaderboardID, forKey: kCategoryLeaderboardID)
        categoryDict.setValue(self.iconFilename, forKey: kCategoryImagePath)
        categoryDict.setValue(self.productIdentifier, forKey: kCategoryProductIdentifier)
        categoryDict.setValue(self.remainingSeconds, forKey: kRemainingSeconds)
        categoryDict.setValue(NSNumber(value: self.showTimer), forKey: kCategoryTimerRequired)
        categoryDict.setValue(NSNumber(value: self.showTimer), forKey: kCategoryTimerRequired)
        return categoryDict
    }
    
    func categoryObject(fromCategoryDict: NSDictionary) -> HACategory
    {
        self.id = (fromCategoryDict[kCategoryID] as! String)
        self.name = (fromCategoryDict[kCategoryName] as! String)
        self.description = fromCategoryDict[kCategoryDescription] as? String
        self.iconFilename = fromCategoryDict[kCategoryImagePath] as? String
        self.categoryId = fromCategoryDict[kCategoryID] as? String
        self.leaderboardID = fromCategoryDict[kCategoryLeaderboardID] as? String
        self.themeColorString = fromCategoryDict[kCategoryColor] as? String
        self.showTimer = ((fromCategoryDict[kCategoryTimerRequired] as? NSNumber)?.boolValue)!
        self.questionLimit = Int(fromCategoryDict[kCategoryQuestionsLimit] as! String)!
        self.productIdentifier = fromCategoryDict[kCategoryProductIdentifier] as? String
        self.remainingSeconds = fromCategoryDict[kRemainingSeconds] as? String
        self.subscriptions = fromCategoryDict[kSubscriptions] as? [String]
        return self
    }
}


