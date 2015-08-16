//
//  ViewController.swift
//  plane
//
//  Created by takashi on 2015/08/01.
//  Copyright (c) 2015年 takashi Otaki. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    var myMapView: MKMapView = MKMapView()
    var planeAnnotation: MKPointAnnotation = MKPointAnnotation()
    var planeAnnotationPosition: NSInteger = 0
    var flightpathPolyline: MKGeodesicPolyline = MKGeodesicPolyline()
    var myAnnotation: MKAnnotationView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myLan: CLLocationDegrees = 38.811651
        let myLon: CLLocationDegrees = -97.358588
        
        var center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLan, myLon)
        
        myMapView.frame = self.view.frame
        myMapView.center = self.view.center
        myMapView.centerCoordinate = center
        myMapView.delegate = self
        
        let mySpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
        let myRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, span: mySpan)
        
        myMapView.region = myRegion
        
        self.view.addSubview(myMapView)

        
        var LAX: CLLocation = CLLocation(latitude:33.9424955, longitude:-118.4080684)
        var JFK: CLLocation = CLLocation(latitude:40.6397511, longitude:-73.7789256)
        
        var coordinate:[CLLocationCoordinate2D] = [LAX.coordinate, JFK.coordinate]
        
        flightpathPolyline = MKGeodesicPolyline(coordinates:&coordinate , count:2)
        
        myMapView.addOverlay(flightpathPolyline)
        
        planeAnnotation = MKPointAnnotation()
        myMapView.addAnnotation(planeAnnotation)
        
        updatePlanePosition()

    }
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        let myPolyLineRendere: MKPolylineRenderer = MKPolylineRenderer(overlay: overlay)
        
        myPolyLineRendere.lineWidth = 5
        
        myPolyLineRendere.strokeColor = UIColor(red: (168/255.0), green: (158/255.0), blue: (147/255.0), alpha: 1.0)
        
        return myPolyLineRendere
    }
    


    func updatePlanePosition() {
    
        let step:NSInteger = 5
        
        if (planeAnnotationPosition + step >= flightpathPolyline.pointCount) {
            
            return;
        
        }
        
        var previousPolyLinePoints = flightpathPolyline.points()
        var previousMapPoint: MKMapPoint = previousPolyLinePoints[planeAnnotationPosition]
        
        planeAnnotationPosition += step
        
        var nextPolyLinePoints = flightpathPolyline.points()
        var nextMapPoint: MKMapPoint = nextPolyLinePoints[planeAnnotationPosition]
        
        var nextCoord: CLLocationCoordinate2D = MKCoordinateForMapPoint(nextMapPoint)
        
        var planeDirection = XXDirectionBetweenPoints(previousMapPoint, nextMapPoint: nextMapPoint)
        
        planeAnnotation.coordinate = nextCoord
        
        myAnnotation.transform = CGAffineTransformRotate(myMapView.transform, XXDegreesToRadians(planeDirection));
        
        let delay = 0.05 * Double(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {

            self.updatePlanePosition()

        })

    }
    
    func XXDirectionBetweenPoints(previousMapPoint: MKMapPoint, nextMapPoint: MKMapPoint) -> CLLocationDirection {
        var x: Double = nextMapPoint.x - previousMapPoint.x
        var y: Double = nextMapPoint.y - previousMapPoint.y
    
        return fmod(XXRadiansToDegrees(atan2(y, x)), 360.0) + 90.0
    }
    
    
    func XXRadiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / M_PI
    }
    
    func XXDegreesToRadians(degrees: Double) -> CGFloat {
        return CGFloat(degrees * M_PI / 180.0)
    }

    
    
    /*
    addAnnotation後に実行される.
    */
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let myIdentifier = "myPin"
        
        if myAnnotation == nil {
            myAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: myIdentifier)
        }
        
        myAnnotation.image = UIImage(named: "plane")!
        myAnnotation.annotation = annotation
                
        return myAnnotation
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

