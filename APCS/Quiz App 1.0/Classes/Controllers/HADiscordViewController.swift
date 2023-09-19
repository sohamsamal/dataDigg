//
//  HADiscordViewController.swift
//  QuizApp Starter Kit All In One 1.0
//

import Foundation
import UIKit
import MessageUI
class HADiscordViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var discordButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var color: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.layer.cornerRadius = 10
        textLabel.layer.borderWidth = 1
        discordButton.layer.borderWidth = 1
        discordButton.layer.cornerRadius = 10
        color = (self.navigationController?.navigationBar.barTintColor)!
        
        self.navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.orange]
        self.navigationItem.titleView = titleLabel
        self.navigationController?.navigationBar.tintColor = .white
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "quizBg"))
    }
    
    @IBAction func discordAction(_ sender: Any) {
        let discordUrl = URL(string: "https://discord.gg/Ztq239Dr8Y")!
        if UIApplication.shared.canOpenURL(discordUrl)
        {
            UIApplication.shared.open(discordUrl)
        } else {
            //redirect to safari because the user doesn't have Instagram
            UIApplication.shared.open(URL(string: "https://discord.gg/Ztq239Dr8Y")!)
        }
    }
}
