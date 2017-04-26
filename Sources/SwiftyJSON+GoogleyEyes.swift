//
//  SwiftyJSON+GoogleyEyes.swift
//  GoogleyEyesCore
//
//  Created by Matthew Wyskiel on 4/17/17.
//
//

import Foundation
import SwiftyJSON


extension JSON {
    public var rfc3339: Date? {
        get {
            guard string != nil else { return nil }
            
            // Create date formatter
            //        NSDateFormatter *dateFormatter = nil;
            //        if (!dateFormatter) {
            let en_US_POSIX = Locale(identifier: "en_US_POSIX")
            let dateFormatter = DateFormatter()
            dateFormatter.locale = en_US_POSIX
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            //        }
            
            // Process
            var date: Date?
            
            var RFC3339String = string!.uppercased()
            RFC3339String = RFC3339String.replacingOccurrences(of: "Z", with: "-0000")
            
            // Remove colon in timezone as iOS 4+ NSDateFormatter breaks. See https://devforums.apple.com/thread/45837
            if RFC3339String.characters.count > 20 {
                let nsRange = NSMakeRange(20, RFC3339String.characters.count - 20)
                // Bridge String to NSString
                let RFC3339StringAsNSString = RFC3339String as NSString
                RFC3339String = RFC3339StringAsNSString.replacingOccurrences(of: ":", with: "", options: [], range: nsRange)
                
            }
            
            if date == nil { // 1996-12-19T16:39:57-0800
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
                date = dateFormatter.date(from: RFC3339String)
            }
            if date == nil { // 1937-01-01T12:00:27.87+0020
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"
                date = dateFormatter.date(from: RFC3339String)
            }
            if date == nil { // 1937-01-01T12:00:27
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
                date = dateFormatter.date(from: RFC3339String)
            }
            if date == nil { // 1937-01-01 12:00:27
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd HH':'mm':'ss"
                date = dateFormatter.date(from: RFC3339String)
            }
            
            if date == nil {
                NSLog("Could not parse RFC3339 date: \"\(String(describing: string))\" Possibly invalid format.")
            }
            
            return date;
        }
        set {
            if newValue != nil {
                let en_US_POSIX = Locale(identifier: "en_US_POSIX")
                let dateFormatter = DateFormatter()
                dateFormatter.locale = en_US_POSIX
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                var string: String?
                if string == nil { // 1996-12-19T16:39:57-0800
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
                    string = dateFormatter.string(from: newValue!)
                }
                if string == nil { // 1937-01-01T12:00:27.87+0020
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"
                    string = dateFormatter.string(from: newValue!)
                }
                if string == nil { // 1937-01-01T12:00:27
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
                    string = dateFormatter.string(from: newValue!)
                }
                
                if string == nil {
                    NSLog("Could not parse RFC3339 date: \"\(String(describing: newValue))\" Possibly invalid format.")
                }
                
                self = JSON(stringLiteral: string!)
            } else {
                self = .null
            }
        }
    }
    public var rfc3339Value: Date {
        get {
            if let rfcDate = rfc3339 {
                return rfcDate
            } else {
                return Date(timeIntervalSince1970: 0)
            }
        }
        set {
            rfc3339 = newValue
        }
    }
    
    public var base64: Data? {
        get {
            if let byteString = string {
                return Data(base64Encoded: byteString)
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                self = JSON(stringValue: newValue!.base64EncodedString())
            } else {
                self = .null
            }
        }
    }
    public var base64Value: Data {
        get {
            if let base64Data = base64 {
                return base64Data
            } else {
                return Data()
            }
        }
        set {
            base64 = newValue
        }
    }
    
}

// [String: T]
extension JSON {
    public func toJSONSubtypeDictionary<T>() -> [String: T]? {
        let dict = self.dictionary
        let returnValSet = dict?.flatMap { (item: (key: String, value: JSON)) -> (String, T)? in
            if let val = item.value.object as? T {
                return (item.key, val)
            } else {
                return nil
            }
        }
        var returnVal: [String: T]? = [:]
        for (key, value) in returnValSet! {
            returnVal?[key] = value
        }
        
        return returnVal
    }
    
    public func toJSONSubtypeDictionaryValue<T>() -> [String: T] {
        let dict = self.dictionaryValue
        let returnValSet = dict.flatMap { (item: (key: String, value: JSON)) -> (String, T)? in
            if let val = item.value.object as? T {
                return (item.key, val)
            } else {
                return nil
            }
        }
        
        var returnVal: [String: T] = [:]
        for (key, value) in returnValSet {
            returnVal[key] = value
        }
        
        return returnVal
    }
}
// [T]
extension JSON {
    public func toJSONSubtypeArrayValue<T>() -> [T] {
        let array = arrayValue
        let returnVal: [T] = array.flatMap {
            if let val = $0.object as? T {
                return val
            } else {
                return nil
            }
        }
        return returnVal
    }
    public func toJSONSubtypeArray<T>() -> [T]? {
        let array = self.array
        let returnVal: [T]? = array?.flatMap {
            if let val = $0.object as? T {
                return val
            } else {
                return nil
            }
        }
        return returnVal
    }
}

// [String: T]
extension JSON {
    public func toModelDictionary<T: FromJSON>() -> [String: T]? {
        let dict = self.dictionary
        let returnValSet = dict?.flatMap { (item: (key: String, value: JSON)) -> (String, T)? in
            return (item.key, T(json: item.value))
        }
        var returnVal: [String: T]? = [:]
        for (key, value) in returnValSet! {
            returnVal?[key] = value
        }
        
        return returnVal
    }
    
    public func toModelDictionaryValue<T: FromJSON>() -> [String: T] {
        let dict = self.dictionaryValue
        let returnValSet = dict.flatMap { (item: (key: String, value: JSON)) -> (String, T)? in
            return (item.key, T(json: item.value))
        }
        
        var returnVal: [String: T] = [:]
        for (key, value) in returnValSet {
            returnVal[key] = value
        }
        
        return returnVal
    }
}
// [T]
extension JSON {
    public func toModelArrayValue<T: FromJSON>() -> [T] {
        let array = arrayValue
        let returnVal: [T] = array.flatMap {
            return T(json: $0)
        }
        return returnVal
    }
    public func toModelArray<T: FromJSON>() -> [T]? {
        let array = self.array
        let returnVal: [T]? = array?.flatMap {
            return T(json: $0)
        }
        return returnVal
    }
}

extension JSON {
    init<T: FromJSON>(modelDict: [String: T]) {
        var dict = [String: Any]()
        for (key, value) in modelDict {
            dict[key] = value.toJSON()
        }
        self = JSON(dict)
    }
}
