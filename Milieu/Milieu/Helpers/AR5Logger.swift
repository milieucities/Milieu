//
//  AR5Logger.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-06.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Foundation

/**
 Helper class including methods to print logs in different mode.
*/
class AR5Logger{
   
    /**
     Print the debug log
     
     - Parameter string: The information need to print in debug mode
    */
    class func debug(string: String){
        debugPrint("\(string)")
    }
}