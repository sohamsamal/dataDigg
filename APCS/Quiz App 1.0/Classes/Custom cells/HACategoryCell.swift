//
//  HACategoryCell.swift
//  Quiz App Starter Kit All In One 1.0
//

import UIKit



class HACategoryCell : UITableViewCell
{
   
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: HACustomLabel!
    @IBOutlet weak var categoryDescriptionLabel: HACustomLabel!
    @IBOutlet weak var highscoreLabel: HACustomLabel!
    @IBOutlet weak var completionPercentageLabel: HACustomLabel!
    @IBOutlet weak var highscoreContainerView: UIStackView!
    
    @IBOutlet weak var buyContainerView: UIStackView!
    @IBOutlet weak var buyButton: HACustomButton!
    //@IBOutlet weak var priceLabel: HACustomLabel! shilpa
    @IBOutlet weak var progressView: UIProgressView!
    
    
    var category : HACategory?   {
        didSet{
            guard let unwrappedCategory = category else {
                return
            }
            
            let imagePath = HAQuizDataManager.sharedInstance.iconPathForCategory(category: unwrappedCategory)
            if imagePath == nil{
               
            }
            else{
                self.iconImageView.image = UIImage(contentsOfFile: imagePath!)
            }
            
            self.categoryNameLabel.text = unwrappedCategory.name
            self.categoryDescriptionLabel.text = unwrappedCategory.description
            self.highscoreLabel.text = "\(HAQuizDataManager.sharedInstance.highscoreForCategory(category: unwrappedCategory))"
            self.contentView.backgroundColor = UIColor(hexString: unwrappedCategory.themeColorString!)
            
            
            let questionsCount = HAQuizDataManager.sharedInstance.questionsCount(for: unwrappedCategory)
            let attemptedQuestionsCount = HAQuizDataManager.sharedInstance.attemptedQuestionsCount(for: unwrappedCategory)
            let a = Double(attemptedQuestionsCount)/Double(questionsCount) * 100.0
            let attemptedPercentage = ceil(a) > 100.0 ? 100.0 : a
            self.progressView.progress = Float(attemptedPercentage)/100.0
            self.completionPercentageLabel.text = "\(Int(attemptedPercentage))%"
            //highscoreContainerView.isHidden = true
        }
    }
    
    
}
