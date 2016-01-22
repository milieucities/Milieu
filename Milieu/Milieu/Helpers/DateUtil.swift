//
//  DateUtil.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-21.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation

enum MilieuDateFormat{
    case UTCStandardFormat
    case NoFormat
}
class DateUtil{
    
    /**
     Transform the date string to human readable date string 
     
     - Parameter dateString: The date string needs to be transformed
     - Parameter dateStyle: The `NSDateFormatterStyle` to manage date style
     - Parameter timeStyle: The `NSDateFormmaterStyle` to manage time style
     - Parameter stringFormat: Pre-defined format to identify the dateString
     - Returns: A human readable date and time string
    */
    class func transformStringFromDate(dateString: String?, dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle, stringFormat: MilieuDateFormat) -> String{
        
        if let dateString = dateString{
            let dateFormatter = NSDateFormatter()
            
            switch stringFormat{
            case .UTCStandardFormat:
                dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            case .NoFormat:
                return dateString
            }
            
            if let dateObject = dateFormatter.dateFromString(dateString){
                return NSDateFormatter.localizedStringFromDate(dateObject, dateStyle: dateStyle, timeStyle: timeStyle)
            }else{
                return dateString
            }
        }else{
            return "Unknown"
        }
        
    }
}