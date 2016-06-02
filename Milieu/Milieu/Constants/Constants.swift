//
//  Constants.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-19.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Foundation

struct DefaultsKey {
    static let SelectedNeighbour = "SelectedNeighbour"
}

struct DefaultsValue{
    static let UserCurrentLocation = "UserCurrentLocation"
}

struct Connection{
    static let MilieuServerBaseUrl = "https://milieu.io"
    static let AddictionalHttpHeaders = ["Content-Type": "application/json", "Accept": "application/json"]
    static let OpenNorthBaseUrl = "http://represent.opennorth.ca"
}