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

class MarkOnMapViewController: UIViewController {
    
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
        let point = mapView.screen(toLocation: mapView.center)
        let llPoint = AGSGeometryEngine.projectGeometry(point, to: .wgs84()) as! AGSPoint
        
        if isFromLocation {
            delegate?.didFinishSelectFromLocation(llPoint);
            
        } else {
            delegate?.didFinishSelectToLocation(llPoint);
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
            guard let results = resultSet.results, results.count > 0 else { return }
            
            let filtered = results.filter({ (mp) -> Bool in
                return mp.serviceId == 2
            })
            
            guard filtered.count > 0 else { return }
            let mapPermisson = filtered.first
            
            guard let name = mapPermisson?.name, let localUrl = mapPermisson?.localService?.url, let token = mapPermisson?.localService?.token else { return }
            
            let cred = AGSCredential(token: token, referer: referrer)
            
            let layer = AGSArcGISTiledLayer.init(url: localUrl)
            layer.credential = cred
            layer.name = name
            
            mapView.map = AGSMap.init(basemap: AGSBasemap.init(baseLayer: layer))
            mapView.layerViewStateChangedHandler = { (layer, state) in
                if layer.loadStatus == .loaded {
                    self.layerDidLoad(layer)
                } else if layer.loadStatus == .failedToLoad {
                    self.layer(layer, didFailToLoadWithError: layer.loadError)
                }
            }
            
            mapView.map?.load(completion: { (error) in
                guard error == nil else { print(error?.localizedDescription ?? ""); return }
                self.mapViewDidLoad(self.mapView)
            })
            
        } catch let error as NSError {
            print("error: \(error)");
        }
    }
    
    //MARK: Map view and Layer delegate
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        mapView.locationDisplay.start(completion: nil)
        
        let env = AGSEnvelope(xMin: 10458701.000000, yMin: 542977.875000,
                              xMax: 11986879.000000, yMax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator());
        mapView.setViewpointGeometry(env, completion: nil)
    }
    
    func layerDidLoad(_ layer: AGSLayer!) {
        print("\(layer.name) was loaded");
    }
    
    func layer(_ layer: AGSLayer!, didFailToLoadWithError error: Error!) {
        print("\(layer.name) failed to load by reason: \(String(describing: error))");
    }
    
}
