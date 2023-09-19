//
//  HAGameViewController.swift
//  Quiz App Starter Kit All In One 1.0
//
//

import UIKit
import AVKit
import GameKit
import GoogleMobileAds

class HAGameViewController: UIViewController, AVPlayerViewControllerDelegate, GADFullScreenContentDelegate{
    
    var questions : [HAQuestion]!
    var questionIndex : Int = 0
    var dataManager : HAQuizDataManager!
    var selectedCategory : HACategory!
    var multiplayerMatchDict: NSDictionary!
    var currentPoints: Int = 0
    var videoPlayerController: AVPlayerViewController!
    var avAudioPlayer: AVAudioPlayer!
    var cur: Bool
    var remaining: Int = 0
    var homePressed: Bool = false
    var endOfQuiz: Bool = false
    var minutes: String = ""
    var seconds: String = ""
    var hours: String = "00"
    var TIME: Int = 0
    var canGetPoints: Bool = true
    var wrongAnsClicked: Bool = false
    private var interstitial: GADInterstitialAd?
    
    @IBOutlet weak var topContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var scoreContainerView: UIView!
    @IBOutlet weak var topScoreContainerStackView: UIStackView!
    @IBOutlet weak var progressBarLeftView: UIProgressView!
    @IBOutlet weak var progressBarRightView: UIProgressView!
    
    @IBOutlet var titleView: HACustomLabel!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var countDownLabel: HACustomLabel!
    @IBOutlet weak var userCorrectStackView: UIStackView!
    @IBOutlet weak var nextStackView: UIStackView!
    @IBOutlet var StackViewTextConstraint: NSLayoutConstraint!
    @IBOutlet var StackViewImageConstraint: NSLayoutConstraint!
    
    var timer : Timer?
    //var remainingSeconds : Int
    var timeElapsed: Int
    
    class AdaptableSizeButton: UIButton {
        override var intrinsicContentSize: CGSize {
            let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)) ?? .zero
            let desiredButtonSize = CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
            
            return desiredButtonSize
        }
    }
    
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @IBOutlet weak var optionsContainerStackView: UIStackView!
    @IBOutlet weak var questionTextView: HACustomTextView!
    @IBOutlet weak var mediaContainerView: UIView!
    @IBOutlet weak var currentQuestionLabel: HACustomLabel!
    @IBOutlet weak var pointsLabel: HACustomLabel!
    @IBOutlet weak var Points: HACustomLabel!
    @IBOutlet var optionButtons: [HACustomButton]!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var fullScreenImageView: UIImageView!
    @IBOutlet weak var explanationTitleLabel: HACustomLabel!
    @IBOutlet weak var newQuestionImageView: UIImageView!
    
    @IBOutlet weak var backToQuestion: HACustomButton!
    @IBOutlet weak var explanationTextView: HACustomTextView!
    @IBOutlet var explanationContainerView: UIView!
     @IBOutlet weak var correctAns: HACustomButton!
     @IBOutlet weak var wrongAns: HACustomButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.dataManager = HAQuizDataManager.sharedInstance
        
        /*if (self.selectedCategory.name.contains("4")) {
            self.remainingSeconds = 1800
        } else {
            self.remainingSeconds = TIME
        }*/
        
        self.timeElapsed = 0
        self.cur = true
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
      //  TIME = self.selectedCategory.remainingSeconds
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TIME = Int(self.selectedCategory!.remainingSeconds!)!
       self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: homeButton)
        titleView.text = self.selectedCategory.name
        /*if self.selectedCategory.name.contains("4") {
            TIME = 1800
        } else {
            TIME = 3300
        }*/
        
        
        
        //self.remainingSeconds = self.TIME
        
        self.navigationItem.titleView = titleView

        //let themeColor = UIColor(hexString: selectedCategory.themeColorString!)
        let themeColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
 
        progressBarLeftView.progress = 1
        progressBarLeftView.trackTintColor = .white
        progressBarLeftView.progressTintColor = .black
        
        progressBarRightView.progress = 0
        progressBarRightView.trackTintColor = .black
        progressBarRightView.progressTintColor = .white

        mediaContainerView.backgroundColor = themeColor
        scoreContainerView.backgroundColor = themeColor
        
        questionTextView.backgroundColor = UIColor.white
        self.view.backgroundColor = UIColor.black
        //self.view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "quizBg"))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: skipButton)
        
        var tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(mediaTapped))
        newQuestionImageView.addGestureRecognizer(tapGesture)
        //newQuestionImageView.layer.cornerRadius = newQuestionImageView.frame.size.width / 2
        newQuestionImageView.layer.masksToBounds = true
        newQuestionImageView.backgroundColor = .white
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(fullScreenMediaTapped))
        fullScreenImageView.addGestureRecognizer(tapGesture)
        
        //self.remainingSeconds = remaining
        if self.selectedCategory.showTimer {
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: false)
            timer?.tolerance = 0.15
            RunLoop.current.add(timer!, forMode: .common)
        }
        //self.remainingSeconds = 130
        
        for optionButton in optionButtons{
            
            optionButton.titleLabel?.minimumScaleFactor = 0.5
            optionButton.layer.cornerRadius = 5.0
            optionButton.layer.masksToBounds = true
        }
        
        startQuiz()
        countDownLabel.text = ""
        let correctQuestionsCount = HAQuizDataManager.sharedInstance.correctQuestionsCount(for: self.selectedCategory)
        currentPoints = correctQuestionsCount
        pointsLabel.text = "\(self.currentPoints)"
        currentQuestionLabel.text = "\(questionIndex + 1)/\(questions!.count)"
        
        //self.navigationController?.navigationBar.barTintColor = UIColor(hexString: selectedCategory.themeColorString!, alpha:1.0)
        self.navigationController?.navigationBar.barTintColor = themeColor
        
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
                GADInterstitialAd.load(withAdUnitID:"ca-app-pub-8358263348683173/3046764075",
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
        
        
    }
    

    /// Tells the delegate that the ad failed to present full screen content.
      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
      }

      /// Tells the delegate that the ad presented full screen content.
      func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
      }

      /// Tells the delegate that the ad dismissed full screen content.
      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
      }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //NotificationCenter.default.addObserver(self, selector: #selector(skipQuestionWhenAppComesForeground), name: Notification.Name("skipCurrentQuestion"), object: nil)
        HASettings.sharedInstance.isGameScreenVisible = true //Mark game screen visible
        playBackgroundMusic()
        //topShadowView.layer.cornerRadius = 4.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if videoPlayerController != nil{
            if videoPlayerController.player != nil{
                if videoPlayerController.player?.rate != 0.0 && videoPlayerController.player?.error == nil{
                    return
                }
            }
        }
        
        
        if selectedCategory.showTimer
        {
            if self.timer != nil {
                if (self.timer?.isValid)!
                {
                    self.remaining = Int(self.selectedCategory!.remainingSeconds!)!
                    self.timer?.invalidate()
                }
            }
        }
        
        NotificationCenter.default.removeObserver(self)
        HASettings.sharedInstance.isGameScreenVisible = false //Mark game screen invisible
        stopBackgroundMusic()
        //cheat catching
    }
    
    @IBAction func homeAction(_ sender: Any) {
        HAUtilities.playTapSound()
        //Stop timer
        if selectedCategory.showTimer
        {
            if self.timer != nil {
                if (self.timer?.isValid)!
                {
                
                    let defaults = UserDefaults.standard
                    //defaults.set(remainingSeconds, forKey: "remainingSeconds")
                    
                    defaults.set(true, forKey: "homePressed")
                    self.timer?.invalidate()
                }
            }
        }

        var alert : UIAlertController!
        if UI_USER_INTERFACE_IDIOM() == .pad {
            alert = UIAlertController(title: "Are you sure", message: "Do you want to leave?", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Are you sure", message: "Do you want to leave?", preferredStyle: .actionSheet)
        }
        
        
      //  alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in NSLog("The \"OK\" alert occured.")
       let yesAction = UIAlertAction(title: "Yes, Leave", style: .default, handler: {UIAlertAction in
           self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
        self.navigationController?.popToRootViewController(animated: true)
       })
        // controller.pushedFromGC = false
        // controller.match = turnBasedMatchHelper.currentMatch!
        
      // let yesStatAction = UIAlertAction(title: "Yes, but tell me how i did", style: .default,
      //      handler: { (action) in
            
            // go back to the login view controller
            // go back through the navigation controller
            
     //       let vc = self.storyboard!.instantiateViewController(withIdentifier: "HAStatViewController") as! UINavigationController
  //          self.present(vc, animated: false, completion: nil)

    //    })
    
       
        let yesStatAction = UIAlertAction(title: "Yes, but tell me how i did", style: .default,handler:{ UIAlertAction in
            self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
                       
          
            if self.interstitial != nil {
                self.interstitial?.present(fromRootViewController: self)
              } else {
                print("Ad wasn't ready")
              }
         //   self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
            
            let controller = HAStatViewController.init(nibName: "HAStatViewController", bundle: nil)
            controller.score = Int64(self.currentPoints)
            controller.category = self.selectedCategory
            self.navigationController?.pushViewController(controller, animated: true)
        })
 
        let noAction = UIAlertAction(title: "No, Cancel", style: .cancel, handler: { _ in
            //self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
             })
    
        //UIAlertAction in
          //  self.startOver()
      //  })
        
       alert.addAction(yesAction)
         alert.addAction(yesStatAction)
        alert.addAction(noAction)
        
    
        present(alert, animated: true, completion: nil)
        //self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
    //    self.navigationController?.popToRootViewController(animated: true)
    }
   func statScreen()
   {   let contrller = HAStatViewController.init(nibName: "HAStatViewController", bundle: nil)
    contrller.score = Int64(currentPoints)
    contrller.category = self.selectedCategory
    self.navigationController?.pushViewController(contrller, animated: true)
    }
    private func startQuiz()
    {
        
        canGetPoints = true
        wrongAnsClicked = false
        hideAllOptions()
        //shuffle questions
        if HASettings.sharedInstance.isShuffleQuestionsEnabled{
            if questions.count > 0{
                self.questions = questions.shuffled();
            }
        }
       
        questionIndex = nextNonAttemptedQuestion(category: selectedCategory);
        if questionIndex == 0
        {
            dataManager.restart(for: selectedCategory)
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "endOfQuiz")
            //defaults.set(0, forKey: "currentPoints")
            selectedCategory.remainingSeconds = String(TIME)
            //defaults.set(TIME, forKey: "remainingSeconds")
        }
        showQuestionAtIndex(questionIndex: questionIndex)
    }
    func nextNonAttemptedQuestion(category: HACategory) -> Int {
        
        
        let filePath = docmentsDicrectoryURL.path + "/attempted_questions_for_\(category.id!).plist"
         var attemptedQuestions = NSMutableArray()
        if (FileManager.default.fileExists(atPath: filePath))
        {
            attemptedQuestions = NSMutableArray.init(contentsOfFile: filePath)!
            
            let lastQuestion = attemptedQuestions.lastObject
            if attemptedQuestions.count < questions!.count {
            //if attemptedQuestions.count != 0 || attemptedQuestions.count != questions?.count {
                attemptedQuestions.remove(lastQuestion!)
                
                //attemptedQuestions.remove(questionIndex: questionIndex)
                //attemptedQuestions.removeLastObject()
            }
         //   let at = NSMutableArray(array: attemptedQuestions) as! [HAQuestion]
        }
         self.questions = dataManager.questionsForCategory(category: self.selectedCategory)
  
    
     //   let ques = questions
        for question in questions
        {
            var md5 = question.question!
            if question.mediaFilename != nil{
                md5.append(question.mediaFilename!)
            }
            
            for option in question.options{
                md5.append(option)
            }
            md5 = md5.md5!
            print(" \(question) , \(md5)  ")
         //   let ques = [String](questions!)
         //  if let indic=(ques.index(of: question))! {
           //     let distanceSquared : Double = pow(distance, 2)
         //   } else {
                //failed to convert textfield text to a double
           // }
        //  let indic=ques.index(of: question)
            if (!attemptedQuestions.contains(md5))
            {
                for i in 0...questions.count-1
                {
                    let ch = questions[i] === question
                    if ch == true
                    {return i
                    }
          //      print(" \(question) , \(md5) is from \(indic) ")
                
            }
                return 0
        }
        }
        return 0
    }
    public func showQuestionAtIndex(questionIndex : Int)
    {
        
        //Reset before new question is displayed
        canGetPoints = true
        wrongAnsClicked = false
        var isPaused = true
        if selectedCategory.showTimer
        {
            if self.timer != nil {
                if (self.timer?.isValid)!
                {
                    if (isPaused) {
                        isPaused = false
                        self.remaining = Int(self.selectedCategory!.remainingSeconds!)!
                        self.timer?.invalidate()
                    }
                    
                }
            }
        }
        let themeColor = UIColor(hexString:"#d3ffce")
        correctAns.backgroundColor = themeColor
        wrongAns.backgroundColor = themeColor
        //dimisvideo on question change
        if videoPlayerController != nil{
            if videoPlayerController.player != nil{
                videoPlayerController.dismiss(animated: true) {
                    print("Video dismissed")
                }
            }
        }

        
        explanationContainerView.isHidden = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
        titleView.text = selectedCategory.name
        //self.selectedCategory.remainingSeconds = 0
//        newQuestionImageView.isHidden = true
        //self.navigationController?.navigationBar.isHidden = false
        self.view.isUserInteractionEnabled = true
        fullScreenImageView.isHidden = true
        fullScreenImageView.image = nil
        //----------------------------
        
        if questionIndex >= ((questions?.count)!)
        {
            
            if self.interstitial != nil {
                self.interstitial?.present(fromRootViewController: self)
              } else {
                print("Ad wasn't ready")
              }
         //    let contrller = HAMainViewController.init(nibName: "HAMainViewController", bundle: nil)
           self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
            let contrller = HAStatViewController.init(nibName: "HAStatViewController", bundle: nil)
            contrller.score = Int64(currentPoints)
            contrller.category = self.selectedCategory
            self.navigationController?.pushViewController(contrller, animated: true)
            return
        }else{
            self.questionTextView.text = ""
            let question = questions[questionIndex]
            
            self.dataManager.mark(question: question, asRedFor: selectedCategory)
            
            //center question textview text to center
            //align text center of the question textview
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {

            }
            

            var options = question.options
            /*if HASettings.sharedInstance.isShuffleAnswersEnabled{
                options = question.options?.shuffled()
            }*/
            
            var optionsCount = 4
            var hideMedia = false
            if eQuestionType(rawValue: question.questionType) == eQuestionType.eQuestionTypeText
            {
                hideMedia = true
            }
              else  if eQuestionType(rawValue: question.questionType) == eQuestionType.eQuestionTypeFRQ {
                                  optionsCount = 1
                newQuestionImageView.isHidden = false
                               
                               newQuestionImageView.imageWithFade = UIImage.init(contentsOfFile: self.dataManager.mediaPathForQuestion(question: question, category: selectedCategory))
                               hideMedia = false
                              }
                              
            else if eQuestionType(rawValue: question.questionType) == eQuestionType.eQuestionTypePicture ||  eQuestionType(rawValue: question.questionType) == eQuestionType.eQuestionTypeFRQ
            {
                newQuestionImageView.isHidden = false
                
                newQuestionImageView.imageWithFade = UIImage.init(contentsOfFile: self.dataManager.mediaPathForQuestion(question: question, category: selectedCategory))
                hideMedia = false
            }
            else if eQuestionType(rawValue: question.questionType) == eQuestionType.eQuestionTypeVideo{
                //newQuestionImageView.isHidden = false
                let videoPath = dataManager.mediaPathForQuestion(question: question, category: selectedCategory)
                let asset = AVURLAsset.init(url: URL(fileURLWithPath: videoPath))
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                do{
                    newQuestionImageView.imageWithFade = try UIImage(cgImage: generator.copyCGImage(at: CMTimeMake(value: 3,timescale: 1), actualTime: nil))
                }catch{
                    
                }
                NotificationCenter.default.addObserver(self, selector: #selector(HAGameViewController.dismissVideoOnStop(notification:)), name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object:nil)
                
                hideMedia = false
            }
           // else //true false
           // {
           //     optionsCount = 2
         //   }

            let questionType = eQuestionType(rawValue: question.questionType)
            if self.mediaContainerView.isHidden && ((questionType == eQuestionType.eQuestionTypeText)
                || (questionType == eQuestionType.eQuestionTypeTrueFalse)){
                
                self.questionTextView.text = question.question
                var topCorrect = (self.questionTextView.bounds.size.height - self.questionTextView.contentSize.height * self.questionTextView.zoomScale)/2.0
                topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
                self.questionTextView.contentOffset = CGPoint(x: 0, y: -topCorrect)
                
            }
            else //animate only if previous question is imge/pic
            {
                self.newQuestionImageView.alpha = 0
                UIView.animate(withDuration: 0, animations: {
                    self.mediaContainerView.isHidden = hideMedia
                    if hideMedia{
                        self.newQuestionImageView.alpha = 0
                    }else{
                        self.newQuestionImageView.alpha = 1
                    }
                }) { (completion) in
                    self.questionTextView.text = question.question
                    var topCorrect = (self.questionTextView.bounds.size.height - self.questionTextView.contentSize.height * self.questionTextView.zoomScale)/2.0
                    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
                    self.questionTextView.contentOffset = CGPoint(x: 0, y: -topCorrect)
                }
            }

            
            skipButton.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0, delay:0.0, animations: {
                for optionButton in self.optionButtons{
                    optionButton.alpha = 0.0
                    var frame = optionButton.frame
                    frame.origin.x = -optionButton.frame.size.width
                    optionButton.frame = frame
                }
            }) { [self] (Bool) in
                self.skipButton.isUserInteractionEnabled = true
                self.resetOptionsButtonBackground()
                for i in 0..<(options?.count)!
                {
                    self.optionButtons[i].setTitle(options?[i], for: .normal)
                    
                }
                
                if optionsCount == 4 {
                    self.optionButtons[0].isHidden = false
                    self.optionButtons[1].isHidden = false
                    self.optionButtons[2].isHidden = false
                    self.optionButtons[3].isHidden = false
                    
                    self.optionButtons[2].setBackgroundImage(#imageLiteral(resourceName: "optionBg_default"), for: .normal)
                    self.optionButtons[2].isUserInteractionEnabled = true
                    
                    self.optionButtons[3].setBackgroundImage(#imageLiteral(resourceName: "optionBg_default"), for: .normal)
                    self.optionButtons[3].isUserInteractionEnabled = true
                    
                    self.optionButtons[0].setBackgroundImage(#imageLiteral(resourceName: "optionBg_default"), for: .normal)
                    self.optionButtons[0].isUserInteractionEnabled = true
                    
                    self.optionButtons[1].setBackgroundImage(#imageLiteral(resourceName: "optionBg_default"), for: .normal)
                    self.optionButtons[1].isUserInteractionEnabled = true
                    if eQuestionType(rawValue: question.questionType) == eQuestionType.eQuestionTypePicture {
                        self.view.bringSubviewToFront(self.newQuestionImageView)
                        
                      //  var question = HAQuestion.init()
                        print(question.mediaFilename)
                        if question.mediaFilename != "" {
                            self.StackViewImageConstraint.isActive = true
                            self.StackViewTextConstraint.isActive = false
                        }
                        else {
                            self.StackViewImageConstraint.isActive = false
                            self.StackViewTextConstraint.isActive = true
                            self.newQuestionImageView.isHidden = true
                        }
                    }
                    else {
                        self.StackViewImageConstraint.isActive = false
                        self.StackViewTextConstraint.isActive = true
                    }
                    
                
                    //self.optionsContainerStackView.topAnchor.constraint(equalTo: self.questionTextView.bottomAnchor, constant: 8).isActive = true
                    //self.optionsContainerStackView.topAnchor.constraint(equalTo: self.newQuestionImageView.bottomAnchor, constant: 8).isActive = false
                   
                    
                    //self.newQuestionImageView.isHidden = true
                    self.pointsLabel.isHidden = false
                    self.Points.isHidden = false
                    self.userCorrectStackView.isHidden = true
                    //self.nextStackView.isHidden = true
                    
                } else if optionsCount == 1 {
                    self.optionButtons[0].isHidden = false
                    self.optionButtons[1].isHidden = true
                    self.optionButtons[2].isHidden = true
                    self.optionButtons[3].isHidden = true
                     
                    self.optionButtons[0].setBackgroundImage(#imageLiteral(resourceName: "optionBg_default"), for: .normal)
                    self.optionButtons[0].isUserInteractionEnabled = true
                    
                    self.optionButtons[2].setTitle("", for: .normal)
                    self.optionButtons[2].setBackgroundImage(nil, for: .normal)
                    self.optionButtons[2].isUserInteractionEnabled = false
                    
                    self.optionButtons[3].setTitle("", for: .normal)
                    self.optionButtons[3].setBackgroundImage(nil, for: .normal)
                    self.optionButtons[3].isUserInteractionEnabled = false
                    
                    self.optionButtons[1].setTitle("", for: .normal)
                    self.optionButtons[1].setBackgroundImage(nil, for: .normal)
                    self.optionButtons[1].isUserInteractionEnabled = false
                    self.view.bringSubviewToFront(self.newQuestionImageView)
                    
                  //  var question = HAQuestion.init()
                    print(question.mediaFilename)
                    if question.mediaFilename != "" {
                        self.StackViewImageConstraint.isActive = true
                        self.StackViewTextConstraint.isActive = false
                    }
                    else {
                        self.StackViewImageConstraint.isActive = false
                        self.StackViewTextConstraint.isActive = true
                        self.newQuestionImageView.isHidden = true
                    }
                    //self.newQuestionImageView.heightAnchor.constraint(equalToConstant: 400).isActive = true
                    //self.optionsContainerStackView.topAnchor.constraint(equalTo: self.questionTextView.bottomAnchor, constant: 8).isActive = false
                    //self.optionsContainerStackView.topAnchor.constraint(equalTo: self.newQuestionImageView.bottomAnchor, constant: 8).isActive = true
                    
                    
                 //   var HACategoryCell: UITableViewCell = UITableViewCell(style: nil, reuseIdentifier: nil)
                 //   var category = HACategoryCell.highScoreContainerView
                    
                    //HACategoryCell.highscoreContainerView.isHidden = false
                    self.pointsLabel.isHidden = false
                    self.Points.isHidden = false
                    self.userCorrectStackView.isHidden = false
                    self.nextStackView.isHidden = false
                 //   self.optionButtons[0].backgroundColor = UIColor.green
                  //  self.optionButtons[1].backgroundColor = UIColor.green
                   // self.optionButtons[2].backgroundColor = UIColor.green
                   // self.optionButtons[3].backgroundColor = UIColor.green
                    
                    //self.currentPoints -= Int64(question.negativePoints)
                } else {
                    
                    self.optionButtons[0].isHidden = false
                    self.optionButtons[1].isHidden = false

                    
                    self.optionButtons[2].setTitle("", for: .normal)
                    self.optionButtons[2].setBackgroundImage(nil, for: .normal)
                    self.optionButtons[2].isUserInteractionEnabled = false
                    
                    self.optionButtons[3].setTitle("", for: .normal)
                    self.optionButtons[3].setBackgroundImage(nil, for: .normal)
                    self.optionButtons[3].isUserInteractionEnabled = false
                    
                    self.pointsLabel.isHidden = false
                    self.Points.isHidden = false
                }
                self.animateOptions()
                
                if self.selectedCategory.showTimer
                {
                    /*if self.cur {
                        self.remainingSeconds = 130
                        self.cur = false
                     } else {
                        self.remainingSeconds = self.remaining
                    }*/
                    /*if homePressed {
                        self.remainingSeconds = HAMainViewController.remainingSeconds
                    }*/
                    
                    if UserDefaults.standard.bool(forKey: "homePressed") {
                        UserDefaults.standard.set(self.currentPoints, forKey: "currentPoints")
                        UserDefaults.standard.set(false, forKey: "homePressed")
                        UserDefaults.standard.set(false, forKey: "endOfQuiz")
                    } else if UserDefaults.standard.bool(forKey: "endOfQuiz"){
                        self.selectedCategory.remainingSeconds = String(self.TIME)
                        UserDefaults.standard.set(false, forKey: "endOfQuiz")
                        UserDefaults.standard.set(0, forKey: "currentPoints")
                    } else {
                        self.selectedCategory.remainingSeconds = String(self.remaining)
                    }
                    
                    
                    self.minutes = String(Int(self.selectedCategory!.remainingSeconds!)! / 60)
                    if Int(self.minutes)! >= 60 {
                        self.hours = "0" + String(Int(self.minutes)! / 60)
                        self.minutes = String(Int(self.minutes)! % 60)
                    } else {
                        self.hours = "00"
                    }
                    if Int(self.minutes)! < 10 {
                        self.minutes = "0" + self.minutes
                    }
                    self.seconds = String(Int(self.selectedCategory!.remainingSeconds!)! % 60)
                    if Int(self.seconds)! < 10 {
                        self.seconds = "0" + self.seconds
                    }
                    
                    self.countDownLabel.text = self.hours + ":" + self.minutes + ":" + self.seconds
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
                    self.progressBarLeftView.progress = 1
                    self.progressBarRightView.progress = 0
                }
            }
            currentQuestionLabel.text = "\(questionIndex + 1)/\(questions!.count)"
        }
    }
    
    @objc func updateTimer()
    {
        self.selectedCategory.remainingSeconds = String(Int(self.selectedCategory!.remainingSeconds!)! - 1)
        let question = questions[questionIndex]
        
        self.progressBarLeftView.setProgress(Float(Int(self.selectedCategory!.remainingSeconds!)!)/Float(question.duration), animated: true)
        self.progressBarRightView.setProgress(1.0 - Float(Int(self.selectedCategory!.remainingSeconds!)!)/Float(question.duration), animated: true)
        
        if Int(self.selectedCategory!.remainingSeconds!)! == -1
        {
            self.timer?.invalidate()
            self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
            let contrller = HAStatViewController.init(nibName: "HAStatViewController", bundle: nil)
            contrller.score = Int64(currentPoints)
            contrller.category = self.selectedCategory
            self.navigationController?.pushViewController(contrller, animated: true)
            return
        }
        
        self.minutes = String(Int(self.selectedCategory!.remainingSeconds!)! / 60)
        if Int(self.minutes)! >= 60 {
            self.hours = "0" + String(Int(self.minutes)! / 60)
            self.minutes = String(Int(self.minutes)! % 60)
        } else {
            self.hours = "00"
        }
        if Int(self.minutes)! < 10 {
            self.minutes = "0" + self.minutes
        }
        self.seconds = String(Int(self.selectedCategory!.remainingSeconds!)! % 60)
        if Int(self.seconds)! < 10 {
            self.seconds = "0" + self.seconds
        }
        self.countDownLabel.text = self.hours + ":" + self.minutes + ":" + self.seconds
        
        
        if self.fullScreenImageView.isHidden == false && self.selectedCategory.showTimer{
            
            self.titleView.text = self.selectedCategory.remainingSeconds
        }
        
        if Int(self.selectedCategory!.remainingSeconds!)! == 2
        {
            self.fullScreenImageView.isHidden = true
            self.fullScreenImageView.image = nil
            
            //dimisvideo on question change
            if videoPlayerController != nil{
                if videoPlayerController.player != nil{
                    videoPlayerController.dismiss(animated: true) {
                        print("Video dismissed")
                    }
                }
            }
        }
    }
    
    @IBAction func skipAction(_ sender: Any) {
        HAUtilities.playTapSound()
        questionIndex += 1
        showQuestionAtIndex(questionIndex: questionIndex)
    }
    
    @objc private func nextQuestion()
    {
        questionIndex += 1
        
        showQuestionAtIndex(questionIndex: questionIndex)
        self.selectedCategory.remainingSeconds = String(Int(self.selectedCategory!.remainingSeconds!)! + 1)
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: false)
        
    }
    
    @objc private func mediaTapped()
    {
        let question = questions[questionIndex]
        if eQuestionType(rawValue: question.questionType) == eQuestionType.eQuestionTypeVideo
        {
            let videoURLString = dataManager.mediaPathForQuestion(question: question, category: selectedCategory)
            let avPlayer = AVPlayer(url: URL(fileURLWithPath: videoURLString))
            self.videoPlayerController = AVPlayerViewController.init()
            videoPlayerController.showsPlaybackControls = true
            videoPlayerController.delegate = self
            videoPlayerController.player = avPlayer
            videoPlayerController.modalPresentationStyle = .fullScreen
            self.present(videoPlayerController, animated: false, completion: nil)
            videoPlayerController.player?.play()
        }else{
            
            if fullScreenImageView.isHidden == false{
                return
            }
            
            titleView.text = "\(self.selectedCategory.remainingSeconds)"
            fullScreenImageView.backgroundColor = .black
            self.fullScreenImageView.frame = self.newQuestionImageView.frame;//self.newQuestionImageView.convert(self.newQuestionImageView.frame, to: nil)
            self.fullScreenImageView.isHidden = false

            UIView.animate(withDuration: 0.3, animations: {
                self.fullScreenImageView.frame = (UIApplication.shared.keyWindow?.frame)!
            }) { (_) in
            }
            
            fullScreenImageView.image = UIImage.init(contentsOfFile: self.dataManager.mediaPathForQuestion(question: questions[questionIndex], category: self.selectedCategory))
            self.view.bringSubviewToFront(fullScreenImageView)
            //self.navigationController?.navigationBar.isHidden = true
        }
    }
    
    @objc private func fullScreenMediaTapped()
    {
        titleView.text = selectedCategory.name
        //self.navigationController?.navigationBar.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.fullScreenImageView.frame = self.newQuestionImageView.frame;//self.newQuestionImageView.convert(self.newQuestionImageView.frame, to: nil)
        }) { (_) in
            self.fullScreenImageView.isHidden = true
        }
    }
    
    @IBAction func optionClicked(_ sender: UIButton)
    {
        
        if selectedCategory.showTimer
        {
            self.remaining = Int(self.selectedCategory!.remainingSeconds!)!
            self.timer?.invalidate()
        }
        
        let question = questions[questionIndex]
        let sectedAnswerText = sender.titleLabel?.text!
        let correctAnswerText = question.options[question.answerIndex]
        var explanationText: String?
        var isCorrect = false
        
        if sectedAnswerText == correctAnswerText
        {
            HAUtilities.playCorrectAnswerSound(isCorrect: true)
        isCorrect = true
            self.dataManager.markC(question: question, asRedFor: selectedCategory)
        if selectedCategory.showTimer{
               if HASettings.sharedInstance.isTimerbasedScoreEnabled{
                   let answeredInSeconds = question.duration - Int(self.selectedCategory!.remainingSeconds!)!
                    if answeredInSeconds <= HASettings.sharedInstance.fullPointsBeforeSeconds{
                        currentPoints = currentPoints + Int(Int64(question.points))
                    }
                    else{
                        currentPoints += Int(ceil(Float(currentPoints) * (Float(Int(self.selectedCategory!.remainingSeconds!)!) / Float(question.duration))))
                    }
                }
                else{
                    if eQuestionType(rawValue: question.questionType) != eQuestionType.eQuestionTypeFRQ && canGetPoints && !wrongAnsClicked
                    {
                        currentPoints += question.points
                        canGetPoints = false
                    }
                }
            }else{
                if eQuestionType(rawValue: question.questionType) != eQuestionType.eQuestionTypeFRQ && canGetPoints && !wrongAnsClicked
                {
                    currentPoints += question.points
                    canGetPoints = false
                }
            }
            explanationText = question.correctExplanation
        }
        else{
         //   HAUtilities.playCorrectAnswerSound(isCorrect: false)
            wrongAnsClicked = true
           isCorrect = false
            self.dataManager.markW(question: question, asRedFor: selectedCategory)
           // currentPoints -= Int64(question.negativePoints)
            explanationText = question.wrongExplanation
        }
    
        pointsLabel.text = "\(currentPoints)"
        
        if HASettings.sharedInstance.isHighlightCorrectAnswerEnabled
        {
            highlightCorrectAnswer(isCorrect: isCorrect, selectedOptionButton: sender)
        }
        //self.view.isUserInteractionEnabled = false
        
        if HASettings.sharedInstance.showExplanation {
            showExplanation(isCorrect: isCorrect)
        }
    }
    
    @IBAction func correctAns(_ sender: Any)
           {
              var isCorrect = false
              let question = questions[questionIndex]
              HAUtilities.playCorrectAnswerSound(isCorrect: true)
          //            isCorrect = true
            //          self.dataManager.markC(question: question, asRedFor: selectedCategory)
              
              //            currentPoints += Int64(question.points)
               //     pointsLabel.text = "\(currentPoints)"
                 
             explanationContainerView.isHidden = false
              correctAns.backgroundColor = UIColor.green
                    
                  }
           
       
    @IBAction func wrongAns(_ sender: Any) {
         var isCorrect = false
                     let question = questions[questionIndex]
           HAUtilities.playCorrectAnswerSound(isCorrect: false)
                     isCorrect = false
                     self.dataManager.markW(question: question, asRedFor: selectedCategory)
          explanationContainerView.isHidden = false
        wrongAns.backgroundColor = UIColor.red
       }
    @IBAction func backToQuestion(_ sender: Any) {
        explanationContainerView.isHidden = true
       
        
    }
    private func showExplanation(isCorrect: Bool)
    {
        explanationContainerView.isHidden = false
        self.view.bringSubviewToFront(explanationContainerView)
        self.view.isUserInteractionEnabled = true
        let question = questions[questionIndex]
        if isCorrect{
            explanationTitleLabel.text = "Answer"
            explanationTitleLabel.textColor = UIColor.systemGreen
            print(question.correctExplanation!)
           explanationTextView.text = question.correctExplanation!
        }
        else{
            explanationTitleLabel.text = "Incorrect"
            explanationTitleLabel.textColor = UIColor.systemRed
                   print(question.wrongExplanation!)
            explanationTextView.text = question.wrongExplanation!
        }
    }
    
    @objc private func highlightCorrectAnswer(isCorrect : Bool, selectedOptionButton: UIButton)
    {
        let question = questions[questionIndex]
        let correctAnswerText = question.options[question.answerIndex]


        if isCorrect
        {
           selectedOptionButton.setBackgroundImage(#imageLiteral(resourceName: "optionBg_green"), for: .normal)
        }
        else{
           selectedOptionButton.setBackgroundImage(#imageLiteral(resourceName: "optionBg_red"), for: .normal)
            
            for optionButton in optionButtons
            {
                if optionButton.titleLabel?.text! == correctAnswerText
                {
                    optionButton.setBackgroundImage(#imageLiteral(resourceName: "optionBg_green"), for: .normal)
                    break
                }
            }

            
        }
    }
    
    private func resetOptionsButtonBackground()
    {
        for optionButton in optionButtons
        {
       //     optionButton.setBackgroundImage(#imageLiteral(resourceName: "optionBg_default"), for: .normal)
        }
    }
    
    private func animateOptions()
    {
//        for optionButton in optionButtons
//        {
//            optionButton.alpha = 0
//            UIView.animate(withDuration: 1, animations: {
//                optionButton.alpha = 1
//            }) { (Bool) in
//
//            }
//        }
        
        //disable user interaction while animating options
        skipButton.isUserInteractionEnabled = false
        var yPosition: CGFloat = 0.0
        for optionButton in optionButtons
        {
            var frame = optionButton.frame
            frame.origin.y = optionsContainerStackView.frame.size.height + optionButton.frame.origin.y + optionButton.frame.size.height
            frame.origin.x = 0
            optionButton.frame = frame
            optionButton.alpha = 0.0
        }
                UIView.animate(withDuration: 0, delay:0.0, animations: {
                    for optionButton in self.optionButtons {
                        var frame = optionButton.frame
                        frame.origin.y = yPosition
                        optionButton.frame = frame
                        optionButton.alpha = 1.0
                        yPosition += optionButton.frame.size.height
                    }
                }) { (Bool) in
                    self.skipButton.isUserInteractionEnabled = true
         }
    }
    
    private func hideAllOptions(){
        for optionButton in optionButtons
        {
            optionButton.alpha = 0.0
//            var frame = optionButton.frame
//            frame.origin.x = -optionButton.frame.size.width
//            optionButton.frame = frame
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Handle fraud
    @objc func skipQuestionWhenAppComesForeground()
    {
        nextQuestion()
    }
    
    
  
    //MARK:- AVPlayerViewController Delegtes
    @objc func dismissVideoOnStop(notification: Notification){
        videoPlayerController.dismiss(animated: true, completion: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
        playBackgroundMusic()
    }
    
    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        playerViewController.dismiss(animated: true, completion: nil)
        playBackgroundMusic()
    }
    
    func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
    }
    
    //MARK:- Background music
    func playBackgroundMusic()
    {
        if HASettings.sharedInstance.isSoundsOn{
            let url = URL(fileReferenceLiteralResourceName: "background_music.wav")
            do{
                avAudioPlayer = try AVAudioPlayer.init(contentsOf: url)
                avAudioPlayer.numberOfLoops = -1
                avAudioPlayer.play()
            }catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func stopBackgroundMusic()
    {
        if avAudioPlayer != nil{
            avAudioPlayer.stop()
        }
    }
}
