//
//  HAScoreTableViewCell.swift
//  QuizApp Starter Kit All In One 1.0
//
//  Created by Satish Nerlekar on 22/05/18.
//  Copyright © 2018 Heavenapps. All rights reserved.
//

import UIKit

class HAScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryNameLabel: HACustomLabel!
    @IBOutlet weak var pointsLabel: HACustomLabel!
    @IBOutlet weak var bgImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
