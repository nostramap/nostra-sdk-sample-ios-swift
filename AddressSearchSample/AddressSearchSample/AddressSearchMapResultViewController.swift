//
//  AddressSearchMapResultViewController.swift
//  AddressSearchSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK
import ArcGIS

class AddressSearchMapResultViewController: UIViewController, AGSLayerDelegate, AGSCalloutDelegate  {

    let referrer = ""
    
    @IBOutlet weak var mapView: AGSMapView!
    var result: NTAddressSearchResult?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMap();
    }
    
    //MARK: Callout delegate
    private func callout(_ callout: AGSCallout!, willShowFor feature: AGSFeature!, layer: AGSLayer!, mapPoint: AGSPoint!) -> Bool {
        if let houseNumber = result?.houseNumber, let soiName = result?.localSoiName {
            callout.title = "\(houseNumber), \(soiName)";
        }
        
        if let admin3Name = result?.adminLevel3?.localName, let admin2Name = result?.adminLevel2?.localName,
            let admin1Name = result?.adminLevel1?.localName {
            callout.detail = "\(admin3Name), \(admin2Name), \(admin1Name)"
        }

        return true;
    }
    
    
    //MARK: layer delegate
    func layerDidLoad(_ layer: AGSLayer!) {
        if let result = self.result, let point = result.locationPoint {
            let point = AGSPoint(x: point.longitude, y: point.latitude, spatialReference: AGSSpatialReference.wgs84());
            let mappoint = AGSPoint(fromDegreesDecimalMinutesString: point?.decimalDegreesString(withNumDigits: 7),
                                    with: AGSSpatialReference.webMercator());
            
            mapView.zoom(toScale: 10000, withCenter: mappoint, animated: true);
            
            let graphicLayer = AGSGraphicsLayer();
            mapView.addMapLayer(graphicLayer);
            
            let symbol = AGSPictureMarkerSymbol(imageNamed: "pin_map");
            let graphic = AGSGraphic(geometry: mappoint, symbol: symbol, attributes: nil);
            graphicLayer.addGraphic(graphic);
            mapView.callout.show(at: mappoint, for: graphic, layer: graphicLayer, animated: true);
        }
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
}
