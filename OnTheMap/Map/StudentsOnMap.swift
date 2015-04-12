//
//  StudentsOnMap.swift
//  OnTheMap
//
//  Pin all students on Map and center the map at my location
//  Customized Annotation is added so when clicked we can fire up a browser to the pin-ed student medir URL
//  Again check network connectivity 
//
//  Created by JeffreyZhang on 4/5/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//

import UIKit
import MapKit

class StudentsOnMap: Project3VC, MKMapViewDelegate{
    
    @IBOutlet weak var MyMap: MKMapView!
    var Centerlocation: CLLocation = CLLocation(latitude: 33.755, longitude: -84.39) // GA Tech
    let myDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    
    // MARK: check network
    override func viewDidLoad() {
        super.viewDidLoad()
 
        if(!Utilities.isConnectedToNetwork() ){
            Utilities.showAlert(self, title: "Service not available", message: "Cannot connect to network")
            return
        }

        AddPin4Students()
    }
    
    // MARK: Pin all student on Map
    func AddPin4Students(){
        MyMap.delegate = self
        MyMap.mapType = MKMapType.Standard
  
        var latitudeDeg :CLLocationDegrees
        var longituteDeg:CLLocationDegrees
        
        for me in WebUtilities.sharedInstance().last100Students {

            latitudeDeg  =   me.latitude!.doubleValue
            longituteDeg =   me.longitude!.doubleValue
            
            //add a pin inside a loop...can we use deque technique like table or mapview instead of create one evrytime???
            var mypin = MKPointAnnotation()
            mypin.title =  me.lastName! + "," + me.firstName!
            mypin.subtitle = me.mediaURL
            mypin.coordinate = CLLocationCoordinate2DMake(latitudeDeg, longituteDeg)
            MyMap.addAnnotation(mypin)
            
         }
        // how many students...but any MKAnnotationView???
         println(MyMap.annotations.count)
        
        //center map on current student after post...when just login...we do not have data
        //optional vs nil
          let mylat   = WebUtilities.sharedInstance().CurrentStudent?.latitude
            if ( mylat != nil) {
               if let mylong  = WebUtilities.sharedInstance().CurrentStudent?.longitude! {
                Centerlocation =  CLLocation(latitude: mylat!.doubleValue , longitude: mylong.doubleValue )
            }
        }
  
        centerMapOnLoc()
    }
    
    //MARK :  MapView delegate..so we can launch URL
    func mapView(mapView: MKMapView!,
        viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
            
            if (annotation is MKUserLocation) {
                //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
                //return nil so map draws default view for it (eg. blue dot)...
                return nil
            }
            
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    //only here when drag map (delegate) etc
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIView
            }
            return view
    }

    //click on right callout btn
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        
        if !Utilities.isConnectedToNetwork() {
            Utilities.showAlert(self, title: "Service not available", message: "Cannot connect to network")
            return
        }
        if let targetURL = annotationView.annotation.subtitle! {
            if Utilities.isNetworkAvialable(targetURL) {
                UIApplication.sharedApplication().openURL( NSURL(string: targetURL)!)
            } else {
                Utilities.showAlert(self, title: "Error", message: targetURL + " is invalid")
            }
        } else {
            Utilities.showAlert(self, title: "Error", message: "No URL")
        }
    }

    //center in location and zoom to 1000 KM radius
    func centerMapOnLoc() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(Centerlocation.coordinate,
            100000.0, 1000000.0)
        MyMap.setRegion(coordinateRegion, animated: true)
    }
 
    
 
    // reload data...
    func Refresh(){
        
        if(!Utilities.isConnectedToNetwork() ){
            Utilities.showAlert(self, title: "Service not available", message: "Cannot connect to network")
            return
        }

        
        WebUtilities.sharedInstance().getStudentLocs ({ last100Students, error in
            if let error = error? {
                var errorMsg = error.localizedDescription
                Utilities.showAlert(self, title: "error", message: errorMsg)
            }
            if let last100Students = last100Students? {
                //share the data with table
                WebUtilities.sharedInstance().last100Students = last100Students
                //redraw Pins
                dispatch_async(dispatch_get_main_queue()) {
                    self.AddPin4Students()
                }
            } else {
                println(error)
            }
        } )

    }

}