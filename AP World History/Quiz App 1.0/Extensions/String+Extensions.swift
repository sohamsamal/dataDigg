//
//  String+Extensions.swift
//  QuizApp Starter Kit All In One 1.0
//
//  Created by Satish Nerlekar on 04/07/18.
//  Copyright © 2018 Heavenapps. All rights reserved.
//

import Foundation
public extension String{
    static func isVersionChanged() -> Bool{
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
    
    static func updatePreviousVersion()
    {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            UserDefaults.standard.setValue(version, forKey: "appVersion")
            UserDefaults.standard.synchronize()
        }
    }
}
