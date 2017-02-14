//
//  Constants.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-19.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Foundation
import UIKit

struct DefaultsKey {
    static let SelectedNeighbour = "SelectedNeighbour"
}

struct DefaultsValue{
    static let UserCurrentLocation = "UserCurrentLocation"
}

struct Connection{
    static let MilieuServerBaseUrl = "https://milieu.io"
    static let ApiVersion = "/api/v1"
    static let LoginUrl = "\(MilieuServerBaseUrl)\(ApiVersion)/login"
    static let DevSiteUrl = "\(MilieuServerBaseUrl)\(ApiVersion)/dev_sites"
    static let OldDevSiteUrl = "\(MilieuServerBaseUrl)/dev_sites"
    static let UserUrl = "\(MilieuServerBaseUrl)\(ApiVersion)/user"
    static let AdditionalHttpHeaders = ["Content-Type": "application/json", "Accept": "application/json"]
    static let OpenNorthBaseUrl = "http://represent.opennorth.ca"
}

struct Color{
    static let primary = UIColor(red:158.0/255.0, green:211.0/255.0, blue:225.0/255.0, alpha:1)
}

struct Segue{
    static let authToMapSegue = "authToMapViewSegue"
    static let userToAuthSegue = "userToAuthSegue"
    static let landingToAuthSegue = "landingToAuthSegue"
    static let landingToMapSegue = "landingToMapSegue"
    static let detailToCommentSegue = "deatilToCommentSegue"
}
