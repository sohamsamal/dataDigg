//
//  HACategoriesViewController.swift
//  Quiz App Starter Kit All In One 1.0
//
//

import UIKit
import GoogleMobileAds

class HACategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var titleView: HACustomLabel!
    @IBOutlet weak var tableView: UITableView!
    
    var categories : [HACategory]
    
    let dataManager = HAQuizDataManager.sharedInstance
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    var bannerView: GADBannerView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.categories = dataManager.categoriesForPlay()!
       
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "HACategoryCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        titleView.text = HASettings.sharedInstance.categoriesScreenTitle
        self.navigationItem.titleView = titleView
        
    
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.handlePurchaseNotification(notification:)), name: Notification.Name("handlePurchaseNotification"), object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseNotification),
                                               name: NSNotification.Name(rawValue: QuizProductsPurchaseNotification),
                                               object: nil)
        let ads = GADMobileAds.sharedInstance()
        ads.start { [self] status in
              // Optional: Log each adapter's initialization latency.
              let adapterStatuses = status.adapterStatusesByClassName
              for adapter in adapterStatuses {
                let adapterStatus = adapter.value
                NSLog("Adapter Name: %@, Description: %@, Latency: %f", adapter.key,
                adapterStatus.description, adapterStatus.latency)
              }

                
                bannerView = GADBannerView(adSize: kGADAdSizeBanner)

                addBannerViewToView(bannerView)
                bannerView.adUnitID = "ca-app-pub-8358263348683173/1000374607"
                bannerView.rootViewController = self

                bannerView.load(GADRequest())
            }
        
        

        
        
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: bottomLayoutGuide,
                              attribute: .top,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
       }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if HASettings.sharedInstance.requireAdsDisplay(){
            //bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            //HASettings.sharedInstance.showAdmobBannerAd(for: bannerView, onController: self)
            
            //loadBannerAd()
            //tableViewBottomConstraint.constant = -bannerView.frame.size.height
        } else {
            if bannerView != nil {
                tableViewBottomConstraint.constant = 0
                bannerView.removeFromSuperview()
            }
        }
        
        //call this for refreshing the content with purchased categories
        self.categories = dataManager.categoriesForPlay()!
      if categories.count == 0
                      {
                      let alert = UIAlertController(title: "No Test Bought", message: "PLEASE BUY A PRACTICE TEST TO PLAY", preferredStyle: .alert)
                               let okAction = UIAlertAction(title: "ok", style:  .default,handler:{ UIAlertAction in
                                 
                                   self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
                                   
                                   let controller = HAMainViewController.init(nibName: "HAMainViewController", bundle: nil)
                                   
                                   self.navigationController?.pushViewController(controller, animated: true)
                               })
                               
                                alert.addAction(okAction)
                               
                         present(alert, animated: true, completion: nil)
                      }
        tableView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in self.loadBannerAd()})
    }
    
    func loadBannerAd() {
        let frame = { () -> CGRect in
            if #available(iOS 11.0, *) {
                return self.view.frame.inset(by: self.view.safeAreaInsets)
            } else {
                return self.view.frame
            }
        }()
        let viewWidth = frame.size.width
     
        bannerView.adSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
     
        bannerView.load(GADRequest())
    }
    
    @objc func handlePurchaseNotification(notification: Notification) {
        self.categories = dataManager.categoriesForPlay()!
        self.tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UI_USER_INTERFACE_IDIOM() == .pad{
            return 150.0
        }
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("HACategoryCell", owner: self, options: nil)?.first as! HACategoryCell
        cell.highscoreContainerView.isHidden = false
        cell.buyContainerView.isHidden = true
        cell.selectionStyle = .none
        cell.category = categories[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HAUtilities.playTapSound()
        let category = categories[indexPath.row]
        
        
        let controller = HAGameViewController.init(nibName: "HAGameViewController4", bundle: nil)
        controller.selectedCategory = category
        //self.navigationController?.navigationBar.barTintColor = UIColor(hexString: category.themeColorString!, alpha: 1.0)
        self.navigationController?.navigationBar.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            self.navigationController?.navigationBar.alpha = 1.0
        }
        controller.questions = self.dataManager.questionsForCategory(category: category)
        let questionsCount = HAQuizDataManager.sharedInstance.questionsCount(for: category)
        let attemptedQuestionsCount = HAQuizDataManager.sharedInstance.attemptedQuestionsCount(for: category)
        if questionsCount == attemptedQuestionsCount
        {
            let alert = UIAlertController(title: "All Questions attempted", message: "Do you want to restart?", preferredStyle: .alert)
            //  alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in NSLog("The \"OK\" alert occured.")
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {UIAlertAction in  self.navigationController?.pushViewController(controller, animated: true)})
            
            let noAction = UIAlertAction(title: "No, Cancel", style: .cancel, handler: nil)
            alert.addAction(yesAction)
            alert.addAction(noAction)
            present(alert, animated: true, completion: nil)
        }
        else
        {
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        
    }
}

