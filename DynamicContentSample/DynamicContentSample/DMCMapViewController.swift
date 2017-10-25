//
//  DMCMapViewController.swift
//  DynamicContentSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import ArcGIS
import NOSTRASDK

class DMCMapViewController: UIViewController, AGSLayerDelegate, AGSCalloutDelegate {
    
    let referrer = ""
    
    @IBOutlet weak var mapView: AGSMapView!
    
    var result: NTDynamicContentResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeMap();
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: layer delegate
    func layerDidLoad(_ layer: AGSLayer!) {
        if let result = self.result, let point = result.point {
            let point = AGSPoint(x: point.x, y: point.y, spatialReference: AGSSpatialReference.wgs84())
            
            guard let decString = point?.decimalDegreesString(withNumDigits: 7) else {
                return
            }
            
            let mappoint = AGSPoint(fromDegreesDecimalMinutesString: decString, with: AGSSpatialReference.webMercator());
            
            mapView.zoom(toScale: 10000, withCenter: mappoint, animated: true);
            
            let graphicLayer = AGSGraphicsLayer();
            mapView.addMapLayer(graphicLayer);
            
            let symbol = AGSPictureMarkerSymbol(imageNamed: "pin_map");
            let graphic = AGSGraphic(geometry: mappoint, symbol: symbol, attributes: nil);
            graphicLayer.addGraphic(graphic);
            mapView.callout.show(at: mappoint, for: graphic, layer: graphicLayer, animated: true);
            
        }
    }
    
    //MARK: Callout delegate
    func callout(_ callout: AGSCallout!, willShowFor feature: AGSFeature!, layer: AGSLayer!, mapPoint: AGSPoint!) -> Bool {
        
        guard let result = self.result else {
            return false
        }
        callout.title = result.localName;
        callout.detail = result.localAddress
        
        return true
    }
    
    func initializeMap() {
        
        mapView.callout.delegate = self;
        
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
    
    
    func layer(_ layer: AGSLayer!, didFailToLoadWithError error: Error!) {
        print("\(layer.name) failed to load by reason: \(error)");
    }

}
