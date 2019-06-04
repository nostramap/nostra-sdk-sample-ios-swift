//
//  ViewController.swift
//  MeasurementToolsSample
//
//  Created by Bunyisa Phansamrit on 28/5/2562 BE.
//  Copyright © 2562 Nostra. All rights reserved.
//

import UIKit
import ArcGIS
import NOSTRASDK

class MeasurementToolsViewController: UIViewController  ,  AGSCalloutDelegate , AGSGeoViewTouchDelegate {
    
    let referrer = ""
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var nostraPic: UIImageView!
    
    //var pinList = []
    
    let pinGraphicLayer = AGSGraphicsOverlay()
    let lineGraphicLayer = AGSGraphicsOverlay()
    
    let locationDistance : AGSLocationDistanceMeasurement! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeMap()
        title = "MeasurementToolsSample"
        nostraPic.image = UIImage(named: "logo_watermark_onmap")
        distance.text = "0 m."
       self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    //MARK: Touch Delegate
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {

       // let symbol = AGSPictureMarkerSymbol(image: UIImage(named: "pin_map")!)
        let symbol = AGSSimpleMarkerSymbol(style: .circle, color: .red, size: 15)
        let graphic = AGSGraphic(geometry: mapPoint, symbol: symbol, attributes: nil)

        pinGraphicLayer.graphics.add(graphic)
        
        if pinGraphicLayer.graphics.count > 1 {
          updatePolyline()
        }
        
        
        
    }
    
    func geoView(_ geoView: AGSGeoView, didLongPressAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        
        let symbol = AGSPictureMarkerSymbol(image: UIImage(named: "pin_map")!)
        let graphic = AGSGraphic(geometry: mapPoint, symbol: symbol, attributes: nil)
        
        pinGraphicLayer.graphics.add(graphic)
        
        if pinGraphicLayer.graphics.count > 1 {
            updatePolyline()
        }
    }
    
    func updatePolyline(point: AGSPoint? = nil) {
        let polylineSymbol = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 3.0)
        var points = pinGraphicLayer.graphics.map( { ($0 as! AGSGraphic).geometry as! AGSPoint })
        if let point = point {
            points.append(point)
        }
        let polyline = AGSPolyline.init(points: points)
        let polylineGraphic = AGSGraphic(geometry: polyline, symbol: polylineSymbol, attributes: nil)
        lineGraphicLayer.graphics.add(polylineGraphic)
        var distances = AGSGeometryEngine.geodeticLength(of: polyline, lengthUnit: .meters(), curveType: .normalSection)
        if distances.isNaN {
            distances = 0
        }
        distance.text = (String(format: "%.0f", distances) + " m." )
    }
    
    @IBAction func currentLocation(_ sender: UIButton) {
        self.mapView.locationDisplay.autoPanMode = .recenter
        updatePolyline(point: self.mapView.locationDisplay.mapLocation)
        
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        pinGraphicLayer.graphics.removeAllObjects()
        lineGraphicLayer.graphics.removeAllObjects()
        updatePolyline()
    }
    

    
    func mapViewDidLoad() {
        mapView.locationDisplay.start(completion: nil)
        
        let env = AGSEnvelope(xMin: 10458701.000000, yMin: 542977.875000,
                              xMax: 11986879.000000, yMax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator())
        mapView.setViewpointGeometry(env, completion: nil)
        
        mapView.graphicsOverlays.add(lineGraphicLayer)
        mapView.graphicsOverlays.add(pinGraphicLayer)
       
      
    }
    
    
    func initializeMap() {
        mapView.touchDelegate = self
        mapView.callout.delegate = self
        
        do {
            // Get map permisson.
            let resultSet = try NTMapPermissionService.execute()
            
            // Get Street map HD (service id: 2)
            if let results = resultSet.results, results.count > 0 {
                let filtered = results.filter({ (mp) -> Bool in
                    return mp.serviceId == 2
                })
                
                if filtered.count > 0 {
                    let mapPermisson = filtered.first
                    
                    if let name = mapPermisson?.name, let localUrl = mapPermisson?.localService?.url, let token = mapPermisson?.localService?.token {
                        
                        //TODO: remove credential
                        
                        let cred = AGSCredential(token: token, referer: referrer)
                        let layer = AGSArcGISTiledLayer.init(url: localUrl)
                        layer.credential = cred
                        layer.name = name
                        mapView.map = AGSMap.init(basemap: AGSBasemap.init(baseLayer: layer))
                        mapView.map?.load(completion: { (error) in
                            guard error == nil else {return}
                            self.mapViewDidLoad()
                        })
                        
                    }
                }
            }
        }
        catch let error as NSError {
            print("error: \(error)")
        }
    }
    
}

