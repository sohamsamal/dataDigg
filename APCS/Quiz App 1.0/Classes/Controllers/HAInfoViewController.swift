//
//  HAInfoViewController.swift
//  QuizApp Starter Kit All In One 1.0
//
//

import UIKit
import WebKit

class HAInfoViewController: UIViewController {

    @IBOutlet var titleLabel: HACustomLabel!
    @IBOutlet var homeButton: UIButton!
    @IBOutlet weak var aboutTextView: UITextView!
    // instance of WKWebView
    let wkWebView: WKWebView = {
        let v = WKWebView()
        v.backgroundColor = .clear
        v.isOpaque = false
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // instance of WKWebView
    /*let uiWebView: UIWebView = {
        let v = UIWebView()
        v.backgroundColor = .clear
        v.isOpaque = false
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: homeButton)
        self.navigationItem.titleView = titleLabel
        titleLabel.text = HASettings.sharedInstance.aboutScreenTitle
        navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))

        let aboutString = HASettings.sharedInstance.aboutScreenTextOrURL
        var isURL = false
        var request: URLRequest? = nil
        
        if URL.verifyUrl(urlString: aboutString)
        {
            isURL = true
            request = URLRequest.init(url: URL(string: aboutString)!)
        }

        let minimumVersion = OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)
        //if ProcessInfo().isOperatingSystemAtLeast(minimumVersion) {
            //current version is >= (11)
            if isURL
            {
                aboutTextView.isHidden = true

                self.view.addSubview(wkWebView)
                wkWebView.load(request!)
                if #available(iOS 11.0, *) {
                    wkWebView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
                    wkWebView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
                    wkWebView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
                    wkWebView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
                } else {
                    wkWebView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                    wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                    wkWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
                    wkWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
                }
            }else{
                aboutTextView.text = aboutString
            }/*
        } else {
            //current version is < (11)
            if isURL{
                self.view.addSubview(uiWebView)
                aboutTextView.isHidden = true
                uiWebView.loadRequest(request!)
                if #available(iOS 11.0, *) {
                    uiWebView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
                    uiWebView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
                    uiWebView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
                    uiWebView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
                } else {
                    uiWebView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                    uiWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                    uiWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
                    uiWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
                }
            }
            else{
                aboutTextView.text = aboutString
            }
        }*/
    }

    @IBAction func homeButton(_ sender: Any) {
        HAUtilities.playTapSound()
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
