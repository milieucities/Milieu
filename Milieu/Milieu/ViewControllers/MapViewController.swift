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
    
    // View
    var map: MGLMapView!
    
    // Annotation Data
    
    // CoreData
    var coreDataStack: CoreDataStack!
    var selectedNeighbour: Neighbourhood?
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var locationMenuButton: UIBarButtonItem!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreDataStack = CoreDataManager.sharedManager.coreDataStack
        linkMenuController()
        createMapView()
        
        
        // Add gesture to change the map style
        map.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
            action: "changeStyle:"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        displaySelectedNeighbour()
        populateAnnotations()
    }
    
    // MARK: - View Setup
    func linkMenuController(){
        // Link the menus
        if revealViewController() != nil{
            revealViewController().rearViewRevealWidth = 260
            locationMenuButton.target = revealViewController()
            locationMenuButton.action = "revealToggle:"
            
            revealViewController().rightViewRevealWidth = 220
            menuButton.target = revealViewController()
            menuButton.action = "rightRevealToggle:"
        }
    }
    
    // MARK: - Map View Setup
    func createMapView(){
        // Create the Map View
        map = MGLMapView(frame: view.bounds, styleURL: MGLStyle.lightStyleURL())
        map.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        settleUserLocation()
        view.addSubview(map)
        
        // Set Map Delegate
        map.delegate = self
    }
    
    func settleUserLocation(){
        map.showsUserLocation = true
        map.userTrackingMode = .Follow
    }
    

    func changeStyle(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .Began {
            let styleURLs = [
                MGLStyle.lightStyleURL(),
                MGLStyle.streetsStyleURL(),
                MGLStyle.emeraldStyleURL(),
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
    
    // MARK: - View Controller Logic
    
    func displaySelectedNeighbour(){
        
        // Try to find the neighbourhood bounds
        // Use the current one if those can't be found
        let bounds = NeighbourManager.findBoundsFromNeighbourhood(selectedNeighbour) ?? map.visibleCoordinateBounds
        map.setVisibleCoordinateBounds(bounds, animated: true)
    }
    
    func populateAnnotations(){
        if let neighbour = selectedNeighbour{
            var applicationInfos = [MilieuAnnotation]()
            
            for item in neighbour.devApps!{
                let app = item as! DevApp
                if let _ = app.addresses?.allObjects.first as? Address{
                    let appInfo = ApplicationInfo(devApp: app)
                    applicationInfos.append(appInfo)
                }
            }
            
            map.removeAnnotations(map.annotations ?? [MGLAnnotation]())
            map.showsUserLocation = true
            map.addAnnotations(applicationInfos)
        }
    }
    
}

// MARK: - MGLMapViewDelegate

extension MapViewController: MGLMapViewDelegate{
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        let annotation = annotation as! MilieuAnnotation
        // Make unique reusable identifier for one annotation type
        let identifier = annotation.category.rawValue
        
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier(identifier)
        
        if annotationImage == nil{
            let image = UIImage(named: identifier)!
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: identifier)
        }
        
        return annotationImage
    }
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        print("Annotation is selected")
    }
}