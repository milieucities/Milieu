//
//  MapViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 15/12/6.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Mapbox
import STPopup
import UIKit
import Alamofire

class MapViewController: UIViewController{
    
    // View
    var map: MGLMapView!
    
    // CoreData
    var coreDataStack: CoreDataStack!
    var selectedNeighbour: Neighbourhood?
    
    let defaults = UserDefaults.standard
    
    var devSiteCache: [DevSite]?
    
    let certainDate: Date = {
       var comps = DateComponents()
        // Always show recent 1 year result
        comps.year = -1
        return (Calendar.current as NSCalendar).date(byAdding: comps, to: Date(), options: [])!
    }()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var locationMenuButton: UIBarButtonItem!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreDataStack = CoreDataManager.sharedManager.coreDataStack
        createMapView()
        
        // Add gesture to change the map style
        map.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
            action: #selector(MapViewController.changeStyle(_:))))
        
        settleUserLocation()
        
        // Set the bar appearance in MapView to solve the bug that the first showing close button color is dark blue
        STPopupNavigationBar.appearance().barTintColor = Color.primary
        STPopupNavigationBar.appearance().tintColor = UIColor.white
        STPopupNavigationBar.appearance().barStyle = UIBarStyle.default
        STPopupNavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        displaySitesNearUserLocation()
    }
    
    func showApplicationsInSelectedNeighbour(){
        populateAnnotations()
    }
    
    // MARK: - Map View Setup
    func createMapView(){
        // Create the Map View
        map = MGLMapView(frame: view.bounds, styleURL: MGLStyle.streetsStyleURL(withVersion: 9))
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(map)
        
        // Set Map Delegate
        map.delegate = self
    }
    
    func settleUserLocation(){
        map.showsUserLocation = true
        map.userTrackingMode = .follow
    }
    
    func loadDefaultLocationIfAny(){
        // Load the defaults value
        let defaultNeighbour = defaults.object(forKey: DefaultsKey.SelectedNeighbour) as? String
        selectedNeighbour = NeighbourManager.sharedManager.fetchNeighbourhood(defaultNeighbour ?? "")
        if selectedNeighbour == nil{
            settleUserLocation()
        }else{
            showApplicationsInSelectedNeighbour()
        }
    }
    
    /**
     Displaying sites near user location
    */
    func displaySitesNearUserLocation(){
        if let userCoordinate = map.userLocation?.location?.coordinate{
            AR5Logger.debug("\(userCoordinate)")
            
            if devSiteCache == nil || devSiteCache?.count == 0 {
                // Fetch the nearby dev sites
                Webservice().load(resource: DevSite.nearby(userCoordinate)){
                    result in
                    self.devSiteCache = result
                    self.populateAnnotations()
                }
            }
        }
    }
    

    func changeStyle(_ longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            let styleURLs = [
                MGLStyle.lightStyleURL(withVersion: 9),
                MGLStyle.streetsStyleURL(withVersion: 9),
                MGLStyle.outdoorsStyleURL(withVersion: 9),
                MGLStyle.darkStyleURL(withVersion: 9),
                MGLStyle.satelliteStyleURL(withVersion: 9),
                MGLStyle.satelliteStreetsStyleURL(withVersion: 9)
            ]
            var index = 0
            for styleURL in styleURLs {
                if map.styleURL == styleURL {
                    index = styleURLs.index(of: styleURL)!
                }
            }
            if index == styleURLs.endIndex - 1 {
                index = styleURLs.startIndex
            } else {
                index = index.advanced(by: 1)
            }
            map.styleURL = styleURLs[index]
        }
    }
    
    // MARK: - View Controller Logic
    func populateAnnotations(){
        if let devSiteCache = devSiteCache{
            let devSites = devSiteCache.map{ApplicationInfo(devSite: $0)}
            map.removeAnnotations(map.annotations ?? [MGLAnnotation]())
            map.showsUserLocation = true
            map.addAnnotations(devSites)
        }
    }
}

// MARK: - MGLMapViewDelegate

extension MapViewController: MGLMapViewDelegate{
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        let annotation = annotation as! MilieuAnnotation
        // Make unique reusable identifier for one annotation type
        let identifier = annotation.category.rawValue
        let image = UIImage(named: identifier)!
        
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: identifier)
        
        if annotationImage == nil{
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: identifier)
        }
        
        return annotationImage
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        
        // Deselect the annotation so that it can be chosen again after dismissing the detail view controller
        mapView.deselectAnnotation(annotation, animated: false)
        
        if let annotation = annotation as? ApplicationInfo{
            
            // Create the ApplicationDetailViewController by storyboard
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ApplicationDetailViewController") as! ApplicationDetailViewController
            
            // Set the annotation
            viewController.annotation = annotation
            
            // Use the STPopupController to make the fancy view controller
            let popupController = STPopupController(rootViewController: viewController)
            popupController.containerView.layer.cornerRadius = 4

            // Show it on top of the map view
            popupController.present(in: self)
            
        }
    }
}
