//
//  HACustomControls.swift
//  QuizApp Starter Kit All In One 1.0
//
//  Created by Satish Nerlekar on 27/05/18.
//  Copyright © 2018 Heavenapps. All rights reserved.
//

import Foundation
import UIKit


class HACustomLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textColor = UIColor.init().appTextColor()
    }
}

class HACustomButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setTitleColor(UIColor.init().appTextColor(), for: .normal)
    }
    
    override var intrinsicContentSize: CGSize {
            let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)) ?? .zero
            let desiredButtonSize = CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
            
            return desiredButtonSize
        }
}

class HACustomTextView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textColor = UIColor.init().appTextColor()
    }
}
