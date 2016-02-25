//
//  MapViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 15/12/6.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Mapbox
import UIKit

class MapViewController: UIViewController{
    
    var map: MGLMapView!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var locationMenuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Link the menus
        if revealViewController() != nil{
            revealViewController().rearViewRevealWidth = 260
            locationMenuButton.target = revealViewController()
            locationMenuButton.action = "revealToggle:"
            
            revealViewController().rightViewRevealWidth = 220
            menuButton.target = revealViewController()
            menuButton.action = "rightRevealToggle:"
        }
        
        // Create the Map View
        map = MGLMapView(frame: view.bounds)
        map.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Set initial displaying location
        map.setCenterCoordinate(CLLocationCoordinate2D(latitude: 40.712791, longitude: -73.997848),
            zoomLevel: 19,
            animated: false)
        view.addSubview(map)
        
        // Set Map Delegate
        map.delegate = self
        
        // Add gesture to change the map style
        map.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
            action: "changeStyle:"))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Create the test annotation
        let marker = MGLPointAnnotation()
        marker.coordinate = map.centerCoordinate
        marker.title = "My Marker"
        marker.subtitle = "It's pretty great"
        map.addAnnotation(marker)
        map.selectAnnotation(marker, animated: true)
    }

    
    func changeStyle(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .Began {
            let styleURLs = [
                MGLStyle.streetsStyleURL(),
                MGLStyle.emeraldStyleURL(),
                MGLStyle.lightStyleURL(),
                MGLStyle.darkStyleURL(),
                MGLStyle.satelliteStyleURL(),
                MGLStyle.hybridStyleURL()
            ]
            var index = 0
            for styleURL in styleURLs {
                if map.styleURL == styleURL {
                    index = styleURLs.indexOf(styleURL)!
                }
            }
            if index == styleURLs.endIndex - 1 {
                index = styleURLs.startIndex
            } else {
                index = index.advancedBy(1)
            }
            map.styleURL = styleURLs[index]
        }
    }
}

extension MapViewController: MGLMapViewDelegate{
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        print("Annotation is selected")
    }
}