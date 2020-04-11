//
//  Config.swift
//  Gittker
//
//  Created by uuttff8 on 3/8/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit


struct Config {
    
    struct Date {
        struct Formatter {
            static func custom(_ value: String) -> DateFormatter {
                let formatter = DateFormatter()
                formatter.dateFormat = value
                formatter.locale = Locale(identifier: "en_US")
                
                return formatter
            }
            
            static var iso8601: DateFormatter {
                return custom("yyyy-MM-dd'T'HH:mm:ss.SSS")
            }
            
            static var yearMonthDay: DateFormatter {
                return custom("yyyy-MM-dd")
            }
            
            static var monthDay: DateFormatter {
                return custom("MMMM dd")
            }
        }
    }
    
    struct Nib {
        static func loadNib(name: String?) -> UINib? {
            guard let name = name else {
                return nil
            }
            
            let bundle = Bundle.main
            let nib = UINib(nibName: name, bundle: bundle)
            
            return nib
        }
    }
    
    struct Common {
        struct Regex {
            static var proposalID: String {
                return "SE-([0-9]+)"
            }
            
            static var bugID: String {
                return "SR-([0-9]+)"
            }
        }
    }
    
    struct CacheKeys {
        static let roomsKey = "GittkerRoomsCache"
        static let peopleKey = "GittkerPeopleCache"
        static let roomsChatKey = "GittkerRoomChat"
        static let suggestedRoomsKey = "GittkerSuggestedRoomsKey"
    }
    
    struct Orientation {
        /**
         Force the screen back to portrait orientation
         */
        static func portrait() {
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let value = !isPad
                ? UIInterfaceOrientation.portrait.rawValue
                : UIDevice.current.orientation.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    
    struct Images {
        static var profileLocation: UIImage {
            if UIScreen.main.isDarkMode {
                let image = UIImage(systemName: "location", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large))?
                    .withTintColor(UIColor.white)
                return image!
            } else {
                return UIImage(systemName: "location", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large))!
            }
        }
                
        static var profileEnvelope: UIImage {
            if UIScreen.main.isDarkMode {
                let image = UIImage(systemName: "envelope", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large))?
                    .withTintColor(UIColor.white)
                return image!

            } else {
                return UIImage(systemName: "envelope", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large))!
            }
        }
    }
}

extension Notification.Name {
    static let URLScheme = NSNotification.Name("URLSchemeActivation")
    static let NotificationRegister = Notification.Name("FinishedRegisterNotification")
    static let AppDidBecomeActive = Notification.Name("AppDidBecomeActive")
}



struct Environment {
    static var settings: [String: Any]? {
        guard
            let dict = Bundle.main.infoDictionary,
            let settings = dict["EnvironmentSettings"] as? [String: Any] else {
                return nil
        }
        
        return settings
    }
    
    static var title: String? {
        guard
            let settings = self.settings,
            let title = settings["Title"] as? String else {
                return nil
        }
        
        return title
    }
    
    static var bundleID: String? {
        guard
            let dict = Bundle.main.infoDictionary,
            let identifier = dict["CFBundleIdentifier"] as? String else {
                return nil
        }
        
        return identifier
    }
    
    struct Keys {
        static var notification: String? {
            guard
                let settings = Environment.settings,
                let key = settings["Notification"] as? String,
                key != "" else {
                    return nil
            }
            
            return key
        }
    }
    
    struct Release {
        static var name: String? {
            guard
                let dict = Bundle.main.infoDictionary,
                let name = dict["CFBundleDisplayName"] as? String else {
                    return nil
            }
            
            return name
        }
        
        static var version: String? {
            guard
                let dict = Bundle.main.infoDictionary,
                let name = dict["CFBundleShortVersionString"] as? String else {
                    return nil
            }
            
            return name
        }
        
        static var build: String? {
            guard
                let dict = Bundle.main.infoDictionary,
                let name = dict["CFBundleVersion"] as? String else {
                    return nil
            }
            
            return name
        }
    }
}
