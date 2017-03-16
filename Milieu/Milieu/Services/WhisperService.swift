//
//  WhisperService.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2017-02-18.
//  Copyright © 2017 Atelier Ruderal. All rights reserved.
//

import Foundation
import Whisper

class WhisperService{
    
    class func showWhisper(message: String, controller: UINavigationController){
        let whisperMessage = Message(title: message, backgroundColor: Color.lightRed)
        show(whisper: whisperMessage, to: controller, action: .show)
    }
}
