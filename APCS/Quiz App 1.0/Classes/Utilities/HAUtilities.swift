//
//  HAUtilities.swift
//  Quiz App Starter Kit All In One 1.0
//
//

import Foundation
import AudioToolbox
import UIKit


extension UIImageView{    
    func showFlip(){
        if self.isHidden{
            UIView.transition(with: self, duration: 1, options: [.transitionFlipFromRight,.allowUserInteraction], animations: nil, completion: nil)
            self.isHidden = false
        }
        
    }
    func hideFlip(){
        if !self.isHidden{
            UIView.transition(with: self, duration: 1, options: [.transitionFlipFromLeft,.allowUserInteraction], animations: nil,  completion: nil)
            self.isHidden = true
        }
    }
    
    var imageWithFade:UIImage?{
        get{
            return self.image
        }
        set{
            UIView.transition(with: self,
                              duration: 0.5, options: .transitionFlipFromTop, animations: {
                                self.image = newValue
            }, completion: nil)
        }
    }
}


extension String {
    var md5: String? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        
        let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes, CC_LONG(data.count), &hash)
            return hash
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    var sha1: String? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        
        let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            CC_SHA1(bytes, CC_LONG(data.count), &hash)
            return hash
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

extension UIViewController{
    func isNetworkAvailable() -> Bool {
        let rechability = Reachability()!
        switch rechability.connection
        {
        case .wifi, .cellular:
            print("Reachable via WiFi & Cellular")
            return true
        case .none:
            print("No wifi & cellular")
            let alertController = UIAlertController(title: "Network error", message: "Please try again later", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        return false
    }
}

extension UserDefaults {
    func contains(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}


extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}


extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String) {
        let url = URL(string: urlString)
        self.image = nil
        
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // if not, download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                }
            }
            
        }).resume()
    }
}

extension URL{
    static func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
}


extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
    
    func appTextColor() -> UIColor
    {
        return UIColor(hexString: HASettings.sharedInstance.appTextColor)
    }
}

extension UIViewController{
    @objc func showActivity()
    {
        hideActivity()
        let window = UIApplication.shared.keyWindow
        let progressView = UIView(frame: (window?.bounds)!)
        progressView.backgroundColor = .black
        progressView.alpha = 0.4
        progressView.tag = 555
        progressView.isUserInteractionEnabled = true
        progressView.backgroundColor = .clear//UIColor(red: , green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>)
        window?.addSubview(progressView)
        progressView.center = (window?.center)!
        
        let activityView = UIActivityIndicatorView(style: .whiteLarge)
        progressView.addSubview(activityView)
        activityView.center = progressView.center
        activityView.startAnimating()
        activityView.color = UIColor(hexString: HASettings.sharedInstance.appTextColor)
    }
    
    @objc func hideActivity()
    {
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow
            let progressView = window?.viewWithTag(555)
            if progressView != nil {
                progressView?.removeFromSuperview()
            }
        }
    }
}

extension Array {
    
    func shuffled() -> Array<Element> {
        var indexArray = Array<Int>(indices)
        var index = indexArray.endIndex
        
        let indexIterator = AnyIterator<Int> {
            guard let nextIndex = indexArray.index(index, offsetBy: -1, limitedBy: indexArray.startIndex)
                else { return nil }
            
            index = nextIndex
            let randomIndex = Int(arc4random_uniform(UInt32(index)))
            if randomIndex != index {
                indexArray.swapAt(randomIndex, index)
            }
            
            return indexArray[index]
        }
        
        return indexIterator.map { self[$0] }
    }
}

extension Date {
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
}

public class HAUtilities{
    
    static func isValidUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    public static func playTapSound()
    {
        if HASettings.sharedInstance.isSoundsOn{
            // Play system sound with custom mp3 file
            if let customSoundUrl = Bundle.main.url(forResource: "tap", withExtension: "mp3") {
                var customSoundId: SystemSoundID = 0
                AudioServicesCreateSystemSoundID(customSoundUrl as CFURL, &customSoundId)
                //let systemSoundId: SystemSoundID = 1016  // to play apple's built in sound, no need for upper 3 lines
                AudioServicesAddSystemSoundCompletion(customSoundId, nil, nil, { (customSoundId, _) -> Void in
                    AudioServicesDisposeSystemSoundID(customSoundId)
                }, nil)
                
                AudioServicesPlaySystemSound(customSoundId)
            }
        }
    }
    
    public static func playCorrectAnswerSound(isCorrect: Bool){
        if HASettings.sharedInstance.isSoundsOn{
            // Play system sound with custom mp3 file

            //let reachability = Reachability()!
            var filename = "wrong"
            if isCorrect
            {
                filename = "right"
            }
            
            if let customSoundUrl = Bundle.main.url(forResource: filename, withExtension: "wav") {
                var customSoundId: SystemSoundID = 0
                AudioServicesCreateSystemSoundID(customSoundUrl as CFURL, &customSoundId)
                //let systemSoundId: SystemSoundID = 1016  // to play apple's built in sound, no need for upper 3 lines
                AudioServicesAddSystemSoundCompletion(customSoundId, nil, nil, { (customSoundId, _) -> Void in
                    AudioServicesDisposeSystemSoundID(customSoundId)
                }, nil)
                
                AudioServicesPlaySystemSound(customSoundId)
            }
        }
    }
}


