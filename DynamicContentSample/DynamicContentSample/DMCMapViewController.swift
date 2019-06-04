//
//  DMCMapViewController.swift
//  DynamicContentSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import ArcGIS
import NOSTRASDK

class DMCMapViewController: UIViewController, AGSCalloutDelegate {
    
    let referrer = ""
    
    @IBOutlet weak var mapView: AGSMapView!
    
    var result: NTDynamicContentResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeMap()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func layerDidLoad(_ layer: AGSLayer!) {
        if let result = self.result, let point = result.point {
            let point = AGSPoint(x: point.x!, y: point.y!, spatialReference: AGSSpatialReference.wgs84())
            
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
    }
    
    //MARK: Callout delegate
    func callout(_ callout: AGSCallout, willShowAtMapPoint mapPoint: AGSPoint) -> Bool {
        guard let result = self.result else { return false }
        callout.title = result.localName
        callout.detail = result.localAddress
        
        return true
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
