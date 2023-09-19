//
//  HAQuizDataManager.swift
//  Quiz App Starter Kit All In One 1.0
//
//

import Foundation

let kHighScore = "highscore"
let kJsonFolderPath = "\(Bundle.main.bundlePath)/Quiz Data/JSON_Format"
let kPlistFolderPath = "\(Bundle.main.bundlePath)/Quiz Data/Plist_Format"
let kMediaFolderPath = "\(Bundle.main.bundlePath)/Quiz Data/Pictures_Or_Videos"
let kHiscorePlistFilePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/Quiz_HighScore.plist"
var docmentsDicrectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]


final class HAQuizDataManager{
    
    static let sharedInstance = HAQuizDataManager()
    
    private init() {
        
        setupInitialHighscores()
        updateQuestionsCountForAllCategories() //updates only once when app version changes.
    }
    
    var allCategories : Array<HACategory> = Array()
    
    //MARK:- Score related methods
    func setupInitialHighscores()
    {
        let allCategories = self.loadAllCategories()
        
        if (!FileManager.default.fileExists(atPath: kHiscorePlistFilePath))
        {
            let highsScores = NSMutableArray()
            for category in allCategories!{
                var highScoreDict: Dictionary<String, Any> = Dictionary<String, Any>()
                highScoreDict[kCategoryID] = category.id
                highScoreDict[kCategoryName] = category.name
                highScoreDict[kHighScore] = NSNumber.init(value: 0)
                highsScores.add(highScoreDict)
            }
            highsScores.write(toFile: kHiscorePlistFilePath, atomically: true)
        }
    }
    
    func setHighScore(score : Int64, category: HACategory)
    {
        let highScores = NSMutableArray.init(contentsOfFile: kHiscorePlistFilePath)
        var found = false
        var highScoreDict : NSMutableDictionary = [:]
        for i in 0..<highScores!.count
        {
            highScoreDict = highScores![i] as! NSMutableDictionary
            if highScoreDict.value(forKey: kCategoryID) == nil{
                
            }
            else{
                let categoryID = highScoreDict[kCategoryID] as! String
                if  categoryID == category.id
                {
                    found = true
                    break
                }
            }
        }
        
        if (found)
        {
            let highScore = highScoreDict[kHighScore] as! NSNumber
            if score > highScore.int64Value
            {
                highScoreDict[kHighScore] = NSNumber(value: score)
            }
        }
        else{
            highScoreDict = NSMutableDictionary()
            highScoreDict[kCategoryID] = category.id
            highScoreDict[kCategoryName] = category.name
            highScoreDict[kHighScore] = NSNumber(value: (score <= 0 ? 0 : score))
            highScores?.add(highScoreDict)
        }
        highScores?.write(toFile: kHiscorePlistFilePath, atomically: true)
    }
    
    func highscoreForCategory(category: HACategory) -> Int64
    {
        let highScores = NSMutableArray.init(contentsOfFile: kHiscorePlistFilePath)
        var highScoreDict : NSMutableDictionary
        
        for i in 0..<highScores!.count
        {
            highScoreDict = highScores![i] as! NSMutableDictionary
            if highScoreDict.value(forKey: kCategoryID) == nil{
                return 0
            }
            else{
                let categoryID = highScoreDict[kCategoryID] as! String
                if  categoryID == category.id
                {
                    return (highScoreDict[kHighScore] as! NSNumber).int64Value
                }
            }
        }
        
        return 0
        
    }
    
    //MARK:- Quiz data related methods
    func loadAllCategories() -> [HACategory]? {
        if allCategories.count > 0
        {
            return allCategories
        }
        
        if HASettings.sharedInstance.dataInputFormat == "plist"
        {
            let categoriesRoot = NSDictionary.init(contentsOfFile: "\(kPlistFolderPath)/Quiz_Categories.plist") as! Dictionary<String, Any>
            let categories = categoriesRoot["Categories"]! as! [Dictionary<String,Any>]
            for catDict in categories
            {
                //print(category)
                let category = HACategory()
                category.id = (catDict[kCategoryID] as! String)
                category.name = (catDict[kCategoryName] as! String)
                category.description = catDict[kCategoryDescription] as? String
                category.iconFilename = catDict[kCategoryImagePath] as? String
                category.leaderboardID = catDict[kCategoryLeaderboardID] as? String
                category.themeColorString = catDict[kCategoryColor] as? String
                category.showTimer = (catDict[kCategoryTimerRequired] as? Bool)!
                category.questionLimit = Int(catDict[kCategoryQuestionsLimit] as! String)!
                category.productIdentifier = catDict[kCategoryProductIdentifier] as? String
                category.subscriptions = catDict[kSubscriptions] as? [String]
                category.remainingSeconds = catDict[kRemainingSeconds] as? String
                allCategories.append(category)
            }
        }
        else //json
        {
            do{
                let jsonString = try String.init(contentsOfFile:"\(kJsonFolderPath)/Quiz_Categories.json")
                let jsonData = jsonString.data(using: .utf8)!
                
                if let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as!  [String: Any]
                {
                    let categories = json["Categories"]! as! [Dictionary<String,Any>]
                    for catDict in categories
                    {
                        //print(category)
                        let category = HACategory()
                        category.id = (catDict[kCategoryID] as! String)
                        category.name = (catDict[kCategoryName] as! String)
                        category.description = catDict[kCategoryDescription] as? String
                        category.iconFilename = catDict[kCategoryImagePath] as? String
                        category.leaderboardID = catDict[kCategoryLeaderboardID] as? String
                        category.themeColorString = catDict[kCategoryColor] as? String
                        category.showTimer = (catDict[kCategoryTimerRequired] as? Bool)!
                        category.questionLimit = Int(catDict[kCategoryQuestionsLimit] as! String)!
                        category.productIdentifier = catDict[kCategoryProductIdentifier] as? String
                        category.subscriptions = catDict[kSubscriptions] as? [String]
                        category.remainingSeconds = catDict[kRemainingSeconds] as? String
                        allCategories.append(category)
                    }
                }
            }
            catch let error as NSError {
                print(error.description)
            }
        }
        return allCategories
    }
    
    /*func categoriesForPlay() -> [HACategory]? {
     
     var categories = [HACategory]()
     
     if(!HASettings.sharedInstance.isInAppPurchaseSupported)
     {
     return allCategories
     }
     else{
     for category in allCategories
     {
     if(category.productIdentifier != nil)
     {
     if(isProductPurchased(prodctIdentifier: category.productIdentifier!))
     {
     categories.append(category)
     }
     }
     else{
     categories.append(category)
     }
     }
     
     }
     return categories
     }*/  //shilpa
    
    /*func categoriesForPlay() -> [HACategory]? {
     
     var categories = [HACategory]()
     
     if(!HASettings.sharedInstance.isInAppPurchaseSupported)
     {
     return allCategories
     }
     else{
     for category in allCategories
     {
     if(category.subscriptions != nil)
     {
     if(isSubscribed(prodctIdentifiers: category.subscriptions!))
     {
     categories.append(category)
     }
     }
     else{
     categories.append(category)
     }
     }
     
     }
     return categories
     }*/
    
    func categoriesForPlay() -> [HACategory]? {
        var practice2Enable = false
        var practice1Enable = false
         var practice3Enable = false
         var practice4Enable = false
         var practice5Enable = false
         var practiceBundleEnable = false
        var categories = [HACategory]()
        QuizProducts.RefreshAll()
        if(QuizProducts.daysRemainingOnSubscription(expirationDateKey: practice2ExpirationDateKey) > 0) {
            practice2Enable = true
        }
        if(QuizProducts.daysRemainingOnSubscription(expirationDateKey: practice1ExpirationDateKey) > 0) {
            practice1Enable = true
        }
        if(QuizProducts.daysRemainingOnSubscription(expirationDateKey: practice3ExpirationDateKey) > 0) {
                 practice3Enable = true
             }
        if(QuizProducts.daysRemainingOnSubscription(expirationDateKey: practice4ExpirationDateKey) > 0) {
                 practice4Enable = true
             }
        if(QuizProducts.daysRemainingOnSubscription(expirationDateKey: practice5ExpirationDateKey) > 0) {
                 practice5Enable = true
             }
        if(QuizProducts.daysRemainingOnSubscription(expirationDateKey: practiceBundleExpirationDateKey) > 0) {
                 practiceBundleEnable = true
             }
        for category in allCategories{
            if(category.name.contains("1") && practice1Enable || category.name.contains("2") && practice2Enable ||
                category.name.contains("3") && practice3Enable ||
            category.name.contains("4") && practice4Enable ||
            category.name.contains("5") && practice5Enable ||
            category.name.contains("Bundle") && practiceBundleEnable) ||
                category.subscriptions == nil {
                categories.append(category)
            }
            
        }
        for category in categories {
            print(category.name)
            print("Category:")
        }
        return categories
        
    }
    func paidCategories() -> [HACategory]? {
        
        var categories: Array<HACategory>? = Array()
        
        if(HASettings.sharedInstance.isInAppPurchaseSupported)
        {
            for category in allCategories
            {
                if category.subscriptions != nil {
                    categories?.append(category)
                }
                
                //                if(category.productIdentifier != nil)
                //                {
                //                    if(!isProductPurchased(prodctIdentifier: category.productIdentifier!))
                //                    {
                //                        categories?.append(category)
                //                    }
                //                }
            }
        }
        return categories
    }
    
    func disableAdsIfBougtInAppPurchase() {
        
        guard  let categories = paidCategories() else {
            return
        }
        
        var purchased : Bool = false
        for category in categories {
            guard let subscriptions = category.subscriptions else {
                return
            }
            for prodId in subscriptions {

                if UserDefaults.standard.value(forKey: prodId) == nil {
                    continue
                }
                
                
                purchased = true
                break
            }
            
            if purchased {
                HASettings.sharedInstance.setAdsTurnedOff(show: true)
            }
            
        }
        
    }
    
    
    //    func paidCategories() -> [HACategory]? {
    //
    //        var categories: Array<HACategory>? = Array()
    //
    //        if(HASettings.sharedInstance.isInAppPurchaseSupported)
    //        {
    //            for category in allCategories
    //            {
    //                if(category.productIdentifier != nil)
    //                {
    //                    if(!isProductPurchased(prodctIdentifier: category.productIdentifier!))
    //                    {
    //                        categories?.append(category)
    //                    }
    //                }
    //            }
    //        }
    //        return categories
    //    }
    
    //Questions related methods
    func questionsForCategory(category: HACategory!) -> [HAQuestion]? {
        
        var questions : Array<HAQuestion> = Array()
        
        if HASettings.sharedInstance.dataInputFormat == "plist"
        {
            let rootQuestions = NSDictionary.init(contentsOfFile: "\(kPlistFolderPath)/Quiz_Category_\(category.id!).plist") as! Dictionary<String, Any>
            let questionsArray = rootQuestions["Questions"]! as! [Dictionary<String,Any>]
            for questionDict in questionsArray
            {
                let question = HAQuestion()
                question.question = (questionDict[kQuizQuestion] as! String)
                question.questionType = (questionDict[kQuizQuestionType] as! String)
                if(eQuestionType(rawValue: question.questionType)! == eQuestionType.eQuestionTypeTrueFalse)
                {
                    question.options = ["True", "False"]
                }
                else{
                    question.options = (questionDict[kQuizOptions] as! [String])
                }
                question.mediaFilename = questionDict[kQuizQuestionPictureOrVideoName] as? String
                question.duration = Int(questionDict[kQuizQuestionDutation] as! String)
                question.points = Int(questionDict[kQuizPoints] as! String)
                question.negativePoints = Int(questionDict[kQuizNegativePoints] as! String)
                question.answerIndex = Int(questionDict[kQuizAnswer] as! String)
                question.correctExplanation =  questionDict[kCorrectAnsExplanation] as? String
                question.wrongExplanation = questionDict[kWrongAnsExplanation] as? String
                questions.append(question)
            }
            
        }
        else{
            do{
                let jsonString = try String.init(contentsOfFile:"\(kJsonFolderPath)/Quiz_Category_\(category.id!).json")
                let jsonData = jsonString.data(using: .utf8)!
                
                if let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as!  [String: Any]
                {
                    let questionsArray = json["Questions"]! as! [Dictionary<String,Any>]
                    
                    for questionDict in questionsArray
                    {
                        let question = HAQuestion()
                        question.question = (questionDict[kQuizQuestion] as! String)
                        question.questionType = (questionDict[kQuizQuestionType] as! String)
                        if eQuestionType(rawValue: question.questionType) == eQuestionType.eQuestionTypeTrueFalse
                        {
                            question.options = ["True", "False"]
                        }
                        else{
                            question.options = (questionDict[kQuizOptions] as! [String])
                        }
                        
                        question.mediaFilename = questionDict[kQuizQuestionPictureOrVideoName] as? String
                        question.duration = Int(questionDict[kQuizQuestionDutation] as! String)
                        question.points = Int(questionDict[kQuizPoints] as! String)
                        question.negativePoints = Int(questionDict[kQuizNegativePoints] as! String)
                        question.answerIndex = Int(questionDict[kQuizAnswer] as! String)
                        question.correctExplanation =  questionDict[kCorrectAnsExplanation] as? String
                        question.wrongExplanation = questionDict[kWrongAnsExplanation] as? String
                        questions.append(question)
                    }
                }
            }
            catch let error as NSError
            {
                print(error.description)
            }
        }
        return questions
    }
    
    //MARK:- Statistics related methods
    func mark(question: HAQuestion!, asRedFor category:HACategory!){
        let filePath = docmentsDicrectoryURL.path + "/attempted_questions_for_\(category.id!).plist"
        var attemptedQuestions = NSMutableArray()
        
        if (FileManager.default.fileExists(atPath: filePath))
        {
            attemptedQuestions = NSMutableArray.init(contentsOfFile: filePath)!
        }
        
        var md5 = question.question!
        
        if question.mediaFilename != nil{
            md5.append(question.mediaFilename!)
        }
        
        for option in question.options{
            md5.append(option)
        }
        md5 = md5.md5!
        if (!attemptedQuestions.contains(md5))
        {
            attemptedQuestions.add(md5)
            attemptedQuestions.write(toFile: filePath, atomically: true)
        }
        
    }
    func markC(question: HAQuestion!, asRedFor category:HACategory!){
        
        let filePath2 = docmentsDicrectoryURL.path + "/correct_questions_for_\(category.id!).plist"
        var correctQuestions = NSMutableArray()
        if (FileManager.default.fileExists(atPath: filePath2))
        {
            correctQuestions = NSMutableArray.init(contentsOfFile: filePath2)!
        }
        
        var md5 = question.question!
        
        if question.mediaFilename != nil{
            md5.append(question.mediaFilename!)
        }
        
        for option in question.options{
            md5.append(option)
        }
        md5 = md5.md5!
        if (!correctQuestions.contains(md5))
        {
            correctQuestions.add(md5)
            correctQuestions.write(toFile: filePath2, atomically: true)
        }
        
    }
    func markW(question: HAQuestion!, asRedFor category:HACategory!){
        
        let filePath3 = docmentsDicrectoryURL.path + "/wrong_questions_for_\(category.id!).plist"
        var wrongQuestions = NSMutableArray()
        if (FileManager.default.fileExists(atPath: filePath3))
        {
            wrongQuestions = NSMutableArray.init(contentsOfFile: filePath3)!
        }
        //wrongQuestions = removeDuplicate(wrongQuestions)
        
        var md5 = question.question!
        
        if question.mediaFilename != nil{
            md5.append(question.mediaFilename!)
        }
        
        for option in question.options{
            md5.append(option)
        }
        md5 = md5.md5!
        if (!wrongQuestions.contains(md5))
        {
            wrongQuestions.add(md5)
            wrongQuestions.write(toFile: filePath3, atomically: true)
        }
        
    }
    func restart(for category:HACategory!)
    { let filePath = docmentsDicrectoryURL.path + "/attempted_questions_for_\(category.id!).plist"
        let filePath1 = docmentsDicrectoryURL.path + "/correct_questions_for_\(category.id!).plist"
        let filePath2 = docmentsDicrectoryURL.path + "/wrong_questions_for_\(category.id!).plist"
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: filePath)
            try fileManager.removeItem(atPath: filePath1)
            try fileManager.removeItem(atPath: filePath2)
            //   let text = ""
            //   do {
            //       try text.write(toFile: filePath, atomically: false, encoding: .utf8)
            
        } catch {
            print(error)
        }
    }
    func attemptedQuestionsCount(for category:HACategory!) -> Int
    {
        let filePath = docmentsDicrectoryURL.path + "/attempted_questions_for_\(category.id!).plist"
        if (FileManager.default.fileExists(atPath: filePath))
        {
            let attemptedQuestions = NSMutableArray.init(contentsOfFile: filePath)!
            return attemptedQuestions.count
        }
        return 0
    }
    func correctQuestionsCount(for category:HACategory!) -> Int
    {
        let filePath = docmentsDicrectoryURL.path + "/correct_questions_for_\(category.id!).plist"
        if (FileManager.default.fileExists(atPath: filePath))
        {
            let correctQuestions = NSMutableArray.init(contentsOfFile: filePath)!
            return correctQuestions.count
        }
        return 0
    }
    func wrongQuestionsCount(for category:HACategory!) -> Int
    {
        let filePath = docmentsDicrectoryURL.path + "/wrong_questions_for_\(category.id!).plist"
        if (FileManager.default.fileExists(atPath: filePath))
        {
            let wrongQuestions = NSMutableArray.init(contentsOfFile: filePath)!
            return wrongQuestions.count
        }
        return 0
    }
    
    func updateQuestionsCountForAllCategories()
    {
        var update = false
        
        if _isDebugAssertConfiguration()
        {
            update = true
        }
        
        if String.isVersionChanged() || update
        {
            if let categories = loadAllCategories()
            {
                for category in categories{
                    if let questions = questionsForCategory(category: category)
                    {
                        let key = "questionsCount_\(category.id!)"
                        UserDefaults.standard.set(NSNumber(value: questions.count), forKey: key)
                    }
                }
            }
            String.updatePreviousVersion()
        }
    }
    
    func questionsCount(for category: HACategory!) -> Int
    {
        let key = "questionsCount_\(category.id!)"
        let countNumber = UserDefaults.standard.object(forKey: key) as! NSNumber
        return countNumber.intValue
    }
    
    //MARK:-  In App purchase related methods
    /* func isProductPurchased(prodctIdentifier: String!) -> Bool {
     if (UserDefaults.standard.value(forKey: prodctIdentifier) as? String) != nil
     {
     return true
     }
     return false
     }*/  //shilpa
    
    func isProductPurchased(prodctIdentifiers: [String]!) -> Bool {
        for productId in prodctIdentifiers {
            if (UserDefaults.standard.value(forKey: productId) as? String) != nil
            {
                return true
            }
        }
        return false
    }
    
    
    func isSubscribed(prodctIdentifiers: [String]!) -> Bool {
        for productId in prodctIdentifiers {
            //if (UserDefaults.standard.value(forKey: productId) as? String) != nil
            if(!HAStoreKitManager.sharedInstance.isSubscriptionExpired(productId: productId))
            {
                return true
            }
        }
        return false
    }
    
    // MARK:- Path related methods
    public func mediaPathForQuestion(question: HAQuestion, category: HACategory) -> String
    {
        var imagePath : String
        imagePath = kMediaFolderPath +  "/Quiz_Category_" + category.id + "/" + question.mediaFilename!
        return imagePath
    }
    
    func iconPathForCategory(category : HACategory) -> String?
    {
        var iconFilePath : String
        
        guard let filename = category.iconFilename else {
            return nil
        }
        
        
        
        if HASettings.sharedInstance.dataInputFormat == "plist"
        {
            iconFilePath = kPlistFolderPath +  "/" + filename
        }
        else{
            iconFilePath = kJsonFolderPath  + "/" + filename
        }
        
        if FileManager.default.fileExists(atPath:iconFilePath){
            print("Icon image does not exists at target for category \(String(describing: category.name))")
        }
        
        return iconFilePath
    }
}
