//
//  HAQuestion.swift
//  Quiz App Starter Kit All In One 1.0
//
//

import Foundation

let kQuizQuestion = "question"
let kQuizOptions = "options"
let kQuizAnswer = "Answer"
let kQuizPoints = "points"
let kQuizNegativePoints = "negative_points"
let kQuizQuestionDutation = "duration_in_seconds"
let kQuizQuestionPictureOrVideoName = "picture_or_video_name"
let kQuizQuestionType = "question_type"
let kQuizQuestionVideoName = "video_name"
let kCorrectAnsExplanation = "correct_ans_explanation"
let kWrongAnsExplanation = "wrong_ans_explanation"

public enum eQuestionType : String {
    case eQuestionTypeNone = "0"
    case eQuestionTypeText = "1"
    case eQuestionTypePicture = "2"
    case eQuestionTypeVideo = "3"
    case eQuestionTypeTrueFalse = "4"
    case eQuestionTypeFRQ = "5"
}

class HAQuestion {
    var question : String!
    var options : [String]!
    var mediaFilename : String?
    var answerIndex: Int!
    var points: Int!
    var negativePoints: Int!
    var questionType: String!
    var duration: Int!
    var correctExplanation: String?
    var wrongExplanation: String?
    
   /* enum CodingKeys:String,CodingKey
    {
        case question = "question"
        case answerIndex = "Answer"
        case options = "options"
        case points = "points"
        case negativePoints = "negative_points"
        case correctExplanation = "correct_ans_explanation"
        case wrongExplanation = "wrong_ans_explanation"
        case questionType = "question_type"
        case mediaFilename = "picture_or_video_name"
        case duration = "duration_in_seconds"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        question = try container.decode(String.self, forKey: .question)
        answerIndex = try Int(container.decode(String.self, forKey: .answerIndex))
        points = try Int(container.decode(String.self, forKey: .points))
        negativePoints = try Int(container.decode(String.self, forKey: .negativePoints))
        correctExplanation  = try container.decode(String.self, forKey: .correctExplanation)
        wrongExplanation = try container.decode(String.self, forKey: .wrongExplanation)
        questionType = try container.decode(String.self, forKey: .questionType)
        let d = try container.decode(String.self, forKey: .duration)
        duration = Int(d)
        mediaFilename = try container.decode(String.self, forKey: .mediaFilename)
        options = try container.decode([String].self, forKey: .mediaFilename)
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(question, forKey: .question)
        try container.encode("\(answerIndex)", forKey: .answerIndex)
        try container.encode("\(points)", forKey: .points)
        try container.encode("\(negativePoints)", forKey: .negativePoints)
        try container.encode(correctExplanation, forKey: .correctExplanation)
        try container.encode(wrongExplanation, forKey: .wrongExplanation)
        try container.encode(questionType, forKey: .questionType)
        try container.encode("\(duration)", forKey: .duration)
        try container.encode(mediaFilename, forKey: .mediaFilename)
        try container.encode(options, forKey: .options)
    }*/

    
    func dictionary() -> NSMutableDictionary{
        let questionDict = NSMutableDictionary.init()
        questionDict.setValue(self.question, forKey: kQuizQuestion)
        questionDict.setValue(self.questionType, forKey: kQuizQuestionType)
        questionDict.setValue(self.options, forKey: kQuizOptions)
        questionDict.setValue(self.mediaFilename, forKey: kQuizQuestionPictureOrVideoName)
        questionDict.setValue("\(self.answerIndex!)", forKey: kQuizAnswer)
        questionDict.setValue("\(self.points!)", forKey: kQuizPoints)
        questionDict.setValue("\(self.duration!)", forKey: kQuizQuestionDutation)
        questionDict.setValue("\(self.negativePoints!)", forKey: kQuizNegativePoints)
        questionDict.setValue(self.correctExplanation, forKey: kCorrectAnsExplanation)
        questionDict.setValue(self.wrongExplanation, forKey: kWrongAnsExplanation)
        return questionDict
    }
    
    func questionObject(fromDictionary:NSDictionary) -> HAQuestion
    {
        self.question = (fromDictionary[kQuizQuestion] as! String)
        self.questionType = (fromDictionary[kQuizQuestionType] as! String)
        self.options = (fromDictionary[kQuizOptions] as! [String])
        self.mediaFilename = fromDictionary[kQuizQuestionPictureOrVideoName] as? String
        self.duration = Int(fromDictionary[kQuizQuestionDutation] as! String)
        self.points = Int(fromDictionary[kQuizPoints] as! String)
        self.negativePoints = Int(fromDictionary[kQuizNegativePoints] as! String)
        self.answerIndex = Int(fromDictionary[kQuizAnswer] as! String)
        self.correctExplanation =  fromDictionary[kCorrectAnsExplanation] as? String
        self.wrongExplanation = fromDictionary[kWrongAnsExplanation] as? String
        return self
    }
}


