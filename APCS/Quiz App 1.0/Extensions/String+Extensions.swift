//
//  String+Extensions.swift
//  QuizApp Starter Kit All In One 1.0
//
//

import Foundation
public extension String{
    static public func isVersionChanged() -> Bool{
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if let previousVersion = UserDefaults.standard.value(forKey:"appVersion") as? String{
                if version != previousVersion
                {
                    return true
                }
            }
            else{
                return true
            }
        }else{
            return true
        }
        return false
    }
    
    static public func updatePreviousVersion()
    {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            UserDefaults.standard.setValue(version, forKey: "appVersion")
            UserDefaults.standard.synchronize()
        }
    }
}
