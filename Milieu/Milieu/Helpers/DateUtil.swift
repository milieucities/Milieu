//
//  DateUtil.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-21.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation

enum MilieuDateFormat{
    case utcStandardFormat
    case customizeFormat(format:String, timeZone:TimeZone)
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
    class func transformStringFromDate(_ dateString: String?, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, stringFormat: MilieuDateFormat) -> String{
        
        if let dateString = dateString{
            let dateFormatter = DateFormatter()
            
            switch stringFormat{
            case .utcStandardFormat:
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            case .customizeFormat(let format, let timezone):
                dateFormatter.dateFormat = format
                dateFormatter.timeZone = timezone
            }
            
            if let dateObject = dateFormatter.date(from: dateString){
                return DateFormatter.localizedString(from: dateObject, dateStyle: dateStyle, timeStyle: timeStyle)
            }else{
                return dateString
            }
        }else{
            return "Unknown"
        }
        
    }
    
    class func transformStringFromDate(_ date: Date?, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String{
        
        if let date = date{
            return DateFormatter.localizedString(from: date, dateStyle: dateStyle, timeStyle: timeStyle)
        }else{
            return "Unknown"
        }
        
    }
    
}
