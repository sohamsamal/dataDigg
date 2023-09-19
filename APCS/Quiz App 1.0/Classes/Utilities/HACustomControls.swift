//
//  HACustomControls.swift
//  QuizApp Starter Kit All In One 1.0
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
}

class HACustomTextView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textColor = UIColor.init().appTextColor()
    }
}
