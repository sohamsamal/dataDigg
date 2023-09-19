//
//  GSCustomControls.swift
//
//

import UIKit

@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableButton: UIButton {
    
    override open func prepareForInterfaceBuilder() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        if isSelected {
            guard let sColor = selectedColor else {
                layer.backgroundColor = backgroundColor?.cgColor
                return
            }
            layer.backgroundColor = sColor.cgColor
        } else {
            layer.backgroundColor = defaultColor?.cgColor
        }
    }
    
    override open func awakeFromNib() {
        //TODO :- Need to replace below two lines of code to make generic
        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(.white, for: .selected)
        
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        if isSelected {
            guard let sColor = selectedColor else {
                layer.backgroundColor = backgroundColor?.cgColor
                return
            }
            layer.backgroundColor = sColor.cgColor
        } else {
            layer.backgroundColor = defaultColor?.cgColor
        }
    }
    
    
    @IBInspectable var selectedColor : UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var defaultColor : UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                guard let sColor = selectedColor else {
                    layer.backgroundColor = defaultColor?.cgColor
                    return
                }
                layer.backgroundColor = sColor.cgColor
            } else {
                layer.backgroundColor = defaultColor?.cgColor
            }
        }
    }}

@IBDesignable
class DesignableLabel: UILabel {
}

extension UIView {
    
    override open func prepareForInterfaceBuilder() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
    }
    
    override open func awakeFromNib() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}
