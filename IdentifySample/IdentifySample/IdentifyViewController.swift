//
//  ViewController.swift
//  IdentifySample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK
import ArcGIS
class IdentifyViewController: UIViewController, AGSCalloutDelegate, AGSGeoViewTouchDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    
    let referrer = ""
    
    let graphicLayer = AGSGraphicsOverlay()
    var idenResult: NTIdentifyResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeMap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.idenResult = idenResult
            
        }
    }
    
    func initializeMap() {
        
        mapView.touchDelegate = self
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
            mapView.map?.load(completion: { (error) in
                guard error == nil else { print(error?.localizedDescription ?? ""); return }
                self.mapViewDidLoad(self.mapView)
            })
            
        } catch let error as NSError {
            print("error: \(error)")
        }
    }
    
    @IBAction func btnCurrentLocation_Clicked(_ btn: UIButton) {
        
        mapView.locationDisplay.autoPanMode = .recenter
        
    }
    
    
    //MARK: Touch Delegate
    func geoView(_ geoView: AGSGeoView, didLongPressAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        
        if graphicLayer.graphics.count > 0 {
            graphicLayer.graphics.removeAllObjects()
        }
        
        let symbol = AGSSimpleMarkerSymbol.init(style: .X, color: .red, size: 15)
        
        let graphic = AGSGraphic(geometry: mapPoint, symbol: symbol, attributes: nil)
        graphicLayer.graphics.add(graphic)
        
        DispatchQueue.main.async {
            self.mapView.callout.show(for: graphic, tapLocation: mapPoint, animated: true)
        }
        
    }
    
    //MARK: Callout delegate
    func callout(_ callout: AGSCallout, willShowAtMapPoint mapPoint: AGSPoint) -> Bool {
        
        var show = false
        
        let coordinate2D = mapPoint.toCLLocationCoordinate2D()
        
        let idenParam = NTIdentifyParameter(latitude: coordinate2D.latitude, longitude: coordinate2D.longitude)
        
        if let result = try? NTIdentifyService.execute(idenParam) {
            callout.title = result.localName
            
            if let admin1 = result.adminLevel1?.localName, let admin2 = result.adminLevel2?.localName, let admin3 = result.adminLevel3?.localName {
                callout.detail = "\(admin3), \(admin2), \(admin1)"
            }
            
            if result.nostraId != nil && result.nostraId != "" {
                callout.accessoryButtonType = .detailDisclosure
                callout.isAccessoryButtonHidden = false
            }
            else {
                callout.isAccessoryButtonHidden = true
            }
            
            self.idenResult = result
            
            show = true
        }
        
        return show
    }
    
    func didTapAccessoryButton(for callout: AGSCallout) {
        self.performSegue(withIdentifier: "detailSegue", sender: nil)
    }
    
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        mapView.locationDisplay.start(completion: nil)
        
        let env = AGSEnvelope(xMin: 10458701.000000, yMin: 542977.875000,
                              xMax: 11986879.000000, yMax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator())
        
        mapView.setViewpointGeometry(env, completion: nil)
        graphicLayer.overlayID = "GraphicLyaer"
        mapView.graphicsOverlays.add(graphicLayer)
    }
    
    
    func layerDidLoad(_ layer: AGSLayer!) {
        print("\(layer.name) was loaded")
    }
    
    func layer(_ layer: AGSLayer!, didFailToLoadWithError error: Error!) {
        print("\(layer.name) failed to load by reason: \(error.localizedDescription)")
    }
    
}

