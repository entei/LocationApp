//
//  ViewController.swift
//  LocationApp
//
//  Created by expsk on 5/4/16.
//  Copyright © 2016 pavlovsky. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var coreLocationManager = CLLocationManager()
    // define property, LocationManager - custom library class
    var locationManager: LocationManager!
    //"http://api.tripadvisor.com/api/partner/2.0/map/42.33141,-71.099396?key=HackTripAdvisor-ade29ff43aed"
    let baseUrl = "http://api.tripadvisor.com/api/partner/2.0/map/"
    let apiKey = "HackTripAdvisor-ade29ff43aed"
    
    var numberOfRows = 0
    var namesArray = [String]()

    // when view is load
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        coreLocationManager.delegate = self
        
        // initialize location manager when app running
        locationManager = LocationManager.sharedInstance
        // get current authorization status
        let authCode = CLLocationManager.authorizationStatus()

        // ask for a specific auth status at first start app
        if authCode == CLAuthorizationStatus.NotDetermined && (coreLocationManager.respondsToSelector("requestAllwaysAuthorithation") || coreLocationManager.respondsToSelector("requestWhenInUseAuthorization")) {
                print("Not determined")
                //  if this description is available provide it
                if NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationAlwaysUsageDescription") != nil {
                    coreLocationManager.requestAlwaysAuthorization() // ask for auth
                } else {
                    print("no description for a location auth request")
                }
        } else {
            // only if user already has authorized our app to use location
//            getLocation()
            // start tracking changes in the user’s current location
            coreLocationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        }
    }

//    func getLocation() {
//        // use custom location manager library (current location)
//        locationManager.startUpdatingLocationWithCompletionHandler  { (latitude, longitude, status, verboseMessage, error) -> () in
//            print("\(latitude) : \(longitude)")
//            // we have to use self within a clousure
//            self.displayLocation(CLLocation(latitude: latitude, longitude: longitude))
//        }
//    }
    
//    func displayLocation(location: CLLocation) {
//        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(1, 1))
//            
//        mapView.setRegion(region, animated: true)
//        // create current position point
//        let locationPinCoord = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = locationPinCoord // add pin to annotation
//        // add anotation to map view
//        mapView.addAnnotation(annotation)
//        mapView.showAnnotations([annotation], animated: true)
//        
//        locationManager.reverseGeocodeLocationWithCoordinates(location) { (reverseGecodeInfo, placemark, error) in
//            print(reverseGecodeInfo);
//            let address = reverseGecodeInfo?.objectForKey("formattedAddress") as! String
//            self.locationInfo.text = address
//        }
//    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // if status changed and
        if status != CLAuthorizationStatus.NotDetermined || status != CLAuthorizationStatus.Restricted ||  status != CLAuthorizationStatus.Denied {
            coreLocationManager.startUpdatingLocation()
        }
    }
    
    // will start update location over and over again when startUpdateLocation() is call
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.05, 0.05))
        
        self.mapView.setRegion(region, animated: true)
//        print(location)
        self.coreLocationManager.stopUpdatingLocation()
        fetchInfo(location!.coordinate.latitude, longitude: location!.coordinate.longitude)
    }
    
    func fetchInfo(latitude: Double, longitude: Double) {
        let urlString = "\(baseUrl)\(latitude),\(longitude)/restaurants?key=\(apiKey)"
        let url: NSURL = NSURL(string: urlString)!

        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
    
            do {
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
//                print(String(jsonData))
                self.numberOfRows = jsonData["data"]!.count
                for i in 0...self.numberOfRows {
                    self.namesArray.append("name\(i)")
                }
                // update UI in the main thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            } catch _ {
                print("JSON Error")
            }
        }
        task.resume()
       
    }
    @IBAction func updateLocation(sender: AnyObject) {
//        getLocation()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomTableViewCell
//        cell.textLabel?.text = "asd"  // textLabel may be nil
        if namesArray.count != 0 {
            cell.nameLabel.text = namesArray[indexPath.row]
        }
        return cell
    }

}