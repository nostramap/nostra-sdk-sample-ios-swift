//
//  MarkOnMapViewController.swift
//  RouteSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import ArcGIS
import NOSTRASDK

protocol MarkOnMapDelegate {
    func didFinishSelectFromLocation(_ point: AGSPoint);
    func didFinishSelectToLocation(_ point: AGSPoint);
}

class MarkOnMapViewController: UIViewController, AGSMapViewLayerDelegate, AGSLayerDelegate {

    let referrer = ""
    
    var delegate:MarkOnMapDelegate?;
    
    @IBOutlet weak var mapView: AGSMapView!
    
    
    
    var isFromLocation = false;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.initializeMap();
        
        
    }
    
    
    @IBAction func btnOk_Clicked(_ sender: AnyObject) {
        
        let llPoint = AGSPoint(fromDecimalDegreesString: mapView.mapAnchor.decimalDegreesString(withNumDigits: 7),
                               with: AGSSpatialReference.wgs84())
        
        if isFromLocation {
            delegate?.didFinishSelectFromLocation(llPoint!);
            
        } else {
            delegate?.didFinishSelectToLocation(llPoint!);
        }
        
        _ = self.navigationController?.popViewController(animated: true);
        
    }

    @IBAction func btnCancel_Clicked(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true);
    }
    
    func initializeMap() {
        
        do {
            // Get map permisson.
            let resultSet = try NTMapPermissionService.execute();
            
            // Get Street map HD (service id: 2)
            if let results = resultSet.results, results.count > 0 {
                let filtered = results.filter({ (mp) -> Bool in
                    return mp.serviceId == 2;
                })
                
                if filtered.count > 0 {
                    let mapPermisson = filtered.first;
                    
                    if let name = mapPermisson?.name, let localUrl = mapPermisson?.localService?.url, let token = mapPermisson?.localService?.token {
                        
                        let cred = AGSCredential(token: token, referer: referrer);
                        let tiledLayer = AGSTiledMapServiceLayer(url: localUrl, credential: cred)
                        tiledLayer?.delegate = self;
                        
                        mapView.addMapLayer(tiledLayer, withName: name);
                    }
                }
            }
        }
        catch let error as NSError {
            print("error: \(error)");
        }
    }
    
    //MARK: Map view and Layer delegate
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        mapView.locationDisplay.startDataSource()
        
        let env = AGSEnvelope(xmin: 10458701.000000, ymin: 542977.875000,
                              xmax: 11986879.000000, ymax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator());
        mapView.zoom(to: env, animated: true);
        
    }
    
    
    func layerDidLoad(_ layer: AGSLayer!) {
        print("\(layer.name) was loaded");
    }
    
    func layer(_ layer: AGSLayer!, didFailToLoadWithError error: Error!) {
        print("\(layer.name) failed to load by reason: \(error)");
    }
    
}
