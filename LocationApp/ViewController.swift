//
//  ViewController.swift
//  LocationApp
//
//  Created by expsk on 5/4/16.
//  Copyright © 2016 pavlovsky. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var coreLocationManager = CLLocationManager()
    // define property, LocationManager - custom library class
    var locationManager: LocationManager!
    var mapViewCenter: CLLocationCoordinate2D!
    
    //"http://api.tripadvisor.com/api/partner/2.0/map/42.33141,-71.099396?key=HackTripAdvisor-ade29ff43aed"
    let baseUrl = Settings().baseUrl
    let apiKey = Settings().apiKey
    
    var numberOfRows = 0
    var restaurants = [Restaurant]()
    
    // when view is load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to use delegate methods
        coreLocationManager.delegate = self
        mapView.delegate = self
        
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
//            coreLocationManager.startUpdatingLocation() // start tracking changes in the user’s current location
            showCurrentLocation()
            self.mapView.showsUserLocation = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // if status changed and
        if status != CLAuthorizationStatus.NotDetermined || status != CLAuthorizationStatus.Restricted ||  status != CLAuthorizationStatus.Denied {
//            coreLocationManager.startUpdatingLocation() // start tracking changes in the user’s current location
            showCurrentLocation()
        }
    }
    
    // track user movement
    // will start update location over and over again when startUpdateLocation() is call
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("didUpdateLocations called")
//        let location = locations.last
//        let center = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.03, 0.03))
//        self.mapView.setRegion(region, animated: true)
//        self.coreLocationManager.stopUpdatingLocation()
////        fetchData(location!.coordinate.latitude, longitude: location!.coordinate.longitude, distance: 1)
//    }
    
    func fetchData(latitude: Double, longitude: Double, distance: Int) {
        let urlString = "\(baseUrl)\(latitude),\(longitude)/restaurants?key=\(apiKey)&distance=\(distance)&lunit=km"
        let url: NSURL = NSURL(string: urlString)!

        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            do {
                self.restaurants.removeAll()
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                print("making request...")
                // print(String(jsonData))
                let restaurantsJSONArray = jsonData["data"] as! NSArray
                self.numberOfRows = restaurantsJSONArray.count
                
                for restaurant in restaurantsJSONArray {
                    // populate restaurants array of the JSON response
                    let rest: Restaurant = Restaurant(restDictionary: restaurant as! NSDictionary)
                    self.restaurants.append(rest)
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
    
    @IBAction func reloadButton(sender: AnyObject) {
        // nearest relative to the map center
        findNearestRestaurants()
    }

    func findNearestRestaurants() {
        fetchData(mapViewCenter.latitude, longitude: mapViewCenter.longitude, distance: 2)
//        locationManager.startUpdatingLocationWithCompletionHandler  { (latitude, longitude, status, verboseMessage, error) -> () in
//            print("Your position: \(latitude) : \(longitude)")
//            self.fetchData(latitude, longitude: longitude, distance: 2)
//        }
    }
    
    func showCurrentLocation() {
        locationManager.startUpdatingLocationWithCompletionHandler  { (latitude, longitude, status, verboseMessage, error) -> () in
            print("Your position: \(latitude) : \(longitude)")
            let center = CLLocationCoordinate2DMake(latitude, longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.03, 0.03))
            self.mapView.setRegion(region, animated: true)
            self.fetchData(latitude, longitude: longitude, distance: 2)
        }
    }
    // MARK: - Map view
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapViewCenter = mapView.centerCoordinate
        let mapCenterLatitude = mapView.centerCoordinate.latitude
        let mapCenterLongitude = mapView.centerCoordinate.longitude
        print("Latitude: \(mapCenterLatitude) Longitude: \(mapCenterLongitude)")
    }
    
    // MARK: - Table view
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomTableViewCell
        
        if restaurants.count != 0 {
            cell.nameLabel.text = restaurants[indexPath.row].name
            cell.distanceLabel.text = "\(restaurants[indexPath.row].distance * 1000)m"
            cell.addressLabel.text = restaurants[indexPath.row].address
            cell.ratingLabel.text = restaurants[indexPath.row].rating
            cell.priceLabel.text = restaurants[indexPath.row].price_level
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        showRestaurantAnnotation(restaurants[indexPath.row])
    }
    
    func showRestaurantAnnotation(restaurant: Restaurant) {
        mapView.removeAnnotations(mapView.annotations) // remove old pins
        
        let latitude = (restaurant.latitude as NSString).doubleValue
        let longitude = (restaurant.longitude as NSString).doubleValue
        
        let center = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.05, 0.05))

        mapView.setRegion(region, animated: true)
        // create restaurant pin
        let locationPinCoord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationPinCoord // add annotation to pin
        annotation.title = restaurant.name
        annotation.subtitle = restaurant.address
        // add anotation to map view
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}