//
//  MapResultViewController.swift
//  SearchSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK
import ArcGIS

class MapResultViewController: UIViewController, AGSCalloutDelegate {

    let referrer = ""
    
    @IBOutlet weak var mapView: AGSMapView!
    
    var result: NTLocationSearchResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.initializeMap()
        
    }
    
    //MARK: Callout delegate
    func callout(_ callout: AGSCallout, willShowAtMapPoint mapPoint: AGSPoint) -> Bool {
        guard let result = self.result else { return false }
        
        if let name = result.localName {
            callout.title = name
        }
        
        if let admin1 = result.adminLevel1?.localName, let admin2 = result.adminLevel2?.localName, let admin3 = result.adminLevel3?.localName {
            callout.detail = "\(admin3), \(admin2), \(admin1)"
        }
        
        return true
    }
    
    func layerDidLoad(_ layer: AGSLayer!) {
        guard let result = self.result, let locPoint = result.locationPoint else { return }
        let point = AGSPoint(x: locPoint.longitude!,
                             y: locPoint.latitude!,
                             spatialReference: AGSSpatialReference.wgs84())
        
        mapView.setViewpointCenter(point, scale: 10000, completion: nil)
        let graphicLayer = AGSGraphicsOverlay()
        mapView.graphicsOverlays.add(graphicLayer)
        
        let symbol = AGSPictureMarkerSymbol.init(image: UIImage.init(named: "pin_map")!)
        let graphic = AGSGraphic(geometry: point, symbol: symbol, attributes: nil)
        graphicLayer.graphics.add(graphic)
        
        DispatchQueue.main.async {
            self.mapView.callout.show(for: graphic, tapLocation: point, animated: true)
        }
    }
    

    func initializeMap() {
        
        mapView.callout.delegate = self
        
        do {
            // Get map permisson.
            let resultSet = try NTMapPermissionService.execute()
            
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
            
        } catch let error as NSError {
            print("error: \(error)")
        }
    }
    
    
    func layer(_ layer: AGSLayer!, didFailToLoadWithError error: Error!) {
        print("\(layer.name) failed to load by reason: \(String(describing: error))")
    }
}
