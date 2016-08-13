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

class MapViewController: UIViewController{
    
    // View
    var map: MGLMapView!
    
    // CoreData
    var coreDataStack: CoreDataStack!
    var selectedNeighbour: Neighbourhood?
    
    var events: [EventInfo]!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let certainDate: NSDate = {
       let comps = NSDateComponents()
        // Always show recent 1 year result
        comps.year = -1
        return NSCalendar.currentCalendar().dateByAddingComponents(comps, toDate: NSDate(), options: [])!
    }()
    
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
            action: #selector(MapViewController.changeStyle(_:))))
        
        events = EventInfo.loadAllEvents()
        
        if selectedNeighbour == nil{
            loadDefaultLocationIfAny()
        }else{
            showApplicationsInSelectedNeighbour()
        }
        
        // Set the bar appearance in MapView to solve the bug that the first showing close button color is dark blue
        STPopupNavigationBar.appearance().barTintColor = UIColor(red:158.0/255.0, green:211.0/255.0, blue:225.0/255.0, alpha:1)
        STPopupNavigationBar.appearance().tintColor = UIColor.whiteColor()
        STPopupNavigationBar.appearance().barStyle = UIBarStyle.Default
        STPopupNavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    }
    
    func showApplicationsInSelectedNeighbour(){
        displaySelectedNeighbour()
        populateAnnotations()
    }
    
    // MARK: - View Setup
    func linkMenuController(){
        // Link the menus
        if revealViewController() != nil{
            revealViewController().rearViewRevealWidth = 260
            locationMenuButton.target = revealViewController()
            locationMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rightViewRevealWidth = 220
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
        }
    }
    
    // MARK: - Map View Setup
    func createMapView(){
        // Create the Map View
        map = MGLMapView(frame: view.bounds, styleURL: MGLStyle.streetsStyleURLWithVersion(9))
        map.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        view.addSubview(map)
        
        // Set Map Delegate
        map.delegate = self
    }
    
    func settleUserLocation(){
        map.showsUserLocation = true
        map.userTrackingMode = .Follow
    }
    
    func loadDefaultLocationIfAny(){
        // Load the defaults value
        let defaultNeighbour = defaults.objectForKey(DefaultsKey.SelectedNeighbour) as? String
        selectedNeighbour = NeighbourManager.sharedManager.fetchNeighbourhood(defaultNeighbour ?? "")
        if selectedNeighbour == nil{
            settleUserLocation()
            showLocationSelectionView()
        }else{
            showApplicationsInSelectedNeighbour()
        }
    }
    

    func changeStyle(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .Began {
            let styleURLs = [
                MGLStyle.lightStyleURLWithVersion(9),
                MGLStyle.streetsStyleURLWithVersion(9),
                MGLStyle.outdoorsStyleURLWithVersion(9),
                MGLStyle.darkStyleURLWithVersion(9),
                MGLStyle.satelliteStyleURLWithVersion(9),
                MGLStyle.satelliteStreetsStyleURLWithVersion(9)
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
        map.setVisibleCoordinateBounds(bounds, edgePadding: UIEdgeInsetsMake(5.0, 10.0, 5.0, 10.0), animated: true)
        defaults.setObject(selectedNeighbour!.name, forKey: DefaultsKey.SelectedNeighbour)
        defaults.synchronize()
    }
    
    func populateAnnotations(){
        if let neighbour = selectedNeighbour{
            var applicationInfos = [MilieuAnnotation]()
            
            for item in neighbour.devApps!{
                let app = item as! DevApp
                if let _ = app.address{
                    let appInfo = ApplicationInfo(devApp: app)
                    
                    if let devAppStatus = app.statuses?.reverse().first as? Status{
                        if let statusDate = devAppStatus.statusDate{
//                            if statusDate >= certainDate{
                                applicationInfos.append(appInfo)
//                            }
                        }
                    }
                }
            }
            
            for event in events{
                if event.wardNum == neighbour.number{
                    applicationInfos.append(event)
                }
            }
            
            map.removeAnnotations(map.annotations ?? [MGLAnnotation]())
            map.showsUserLocation = true
            map.addAnnotations(applicationInfos)
        }
    }
    
    
    // MARK: - Segue
    func showLocationSelectionView(){
        self.performSegueWithIdentifier("mapToLocationSelection", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapToLocationSelection"{
            let locationSelectionVC = segue.destinationViewController as! LocationSelectionViewController
            
            // Show the location selection view on top of the current map view
            locationSelectionVC.view.frame = self.view.bounds
            locationSelectionVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            locationSelectionVC.hidesBottomBarWhenPushed = true
        }
    }
    
    // MARK: - Callback from LocationSelectionViewController
    @IBAction func unwindFromLocationSelection(segue: UIStoryboardSegue){
        let locationSelectionController = segue.sourceViewController as! LocationSelectionViewController
        selectedNeighbour = locationSelectionController.selectedNeighbourhood
        showApplicationsInSelectedNeighbour()
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
        
        // Deselect the annotation so that it can be chosen again after dismissing the detail view controller
        mapView.deselectAnnotation(annotation, animated: false)
        
        if let annotation = annotation as? ApplicationInfo{
            
            // Create the ApplicationDetailViewController by storyboard
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ApplicationDetailViewController") as? ApplicationDetailViewController
            
            // Set the annotation
            viewController?.annotation = annotation
            
            // Use the STPopupController to make the fancy view controller
            let popupController = STPopupController(rootViewController: viewController)
            popupController.containerView.layer.cornerRadius = 4

            // Show it on top of the map view
            popupController.presentInViewController(self)
            
        }else if let annotation = annotation as? EventInfo{
            // Create the ApplicationDetailViewController by storyboard
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EventDetailViewController") as? EventDetailViewController
            
            // Set the annotation
            viewController?.annotation = annotation
            
            // Use the STPopupController to make the fancy view controller
            let popupController = STPopupController(rootViewController: viewController)
            popupController.containerView.layer.cornerRadius = 4
            
            // Show it on top of the map view
            popupController.presentInViewController(self)
        }
    }
}