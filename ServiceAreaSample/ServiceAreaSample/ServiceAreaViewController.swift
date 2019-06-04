//
//  ViewController.swift
//  ServiceAreaSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import ArcGIS
import NOSTRASDK

class ServiceAreaViewController: UIViewController, AGSCalloutDelegate , AGSGeoViewTouchDelegate {
    
    let referrer = ""
    
    @IBOutlet weak var mapView: AGSMapView!
    
    let graphicLayer = AGSGraphicsOverlay()
    let serviceAreaLayer = AGSGraphicsOverlay()
    
    let redAreaColor = UIColor(red: 255.0/255.0, green: 0, blue: 0, alpha: 0.5)
    let yellowAreaColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 0, alpha: 0.5)
    let greenAreaColor = UIColor(red: 0, green: 255.0/255.0, blue: 0, alpha: 0.5)
    var idenResult: NTIdentifyResult?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initializeMap()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnCurrentLocation_Clicked(_ btn: UIButton) {
        
        btn.isSelected = !btn.isSelected
        mapView.locationDisplay.autoPanMode = btn.isSelected ? .recenter : .off
        
    }
    
    
    //MARK: Touch Delegate
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Pin Location", style: .default) {
            (alert) in
            
            self.graphicLayer.graphics.removeAllObjects()
            self.serviceAreaLayer.graphics.removeAllObjects()
            
            let graphic = AGSGraphic(geometry: mapPoint,
                                     symbol: AGSPictureMarkerSymbol(image: UIImage(named: "pin_map")!),
                                     attributes: nil)
            
            self.graphicLayer.graphics.add(graphic)
            
            let coordinate2D = mapPoint.toCLLocationCoordinate2D()
            let location = NTLocation(name: "facility", latitude: coordinate2D.latitude , longitude: coordinate2D.longitude)
            let facilities = [location]
            let param = NTServiceAreaParameter(facilities: facilities, breaks: [1, 3, 5])
 
            do {
                let resultSet = try NTServiceAreaService.execute(param)
                guard let results = resultSet.results else { return }
                if results.count == 3 {
                    
                    var area = results[2]
                    var polygonJson = try AGSPolygon.fromJSON(area.shape) as! AGSPolygon
                    var geometry = AGSGeometryEngine.projectGeometry(polygonJson, to: .wgs84())
                    var symbol = AGSSimpleFillSymbol(style: .solid, color: self.redAreaColor, outline: .none )
                    var graphic = AGSGraphic(geometry: geometry, symbol: symbol, attributes: nil)
                    
                    self.serviceAreaLayer.graphics.add(graphic)
                    
                    area = results[1]
                    polygonJson = try AGSPolygon.fromJSON(area.shape) as! AGSPolygon
                    geometry = AGSGeometryEngine.projectGeometry(polygonJson, to: .wgs84())
                    symbol = AGSSimpleFillSymbol(style: .solid, color: self.redAreaColor, outline: .none)
                    graphic = AGSGraphic(geometry: geometry, symbol: symbol, attributes: nil)
                    
                    self.serviceAreaLayer.graphics.add(graphic)
                    
                    area = results[0]
                    polygonJson = try AGSPolygon.fromJSON(area.shape) as! AGSPolygon
                    geometry = AGSGeometryEngine.projectGeometry(polygonJson, to: .wgs84())
                    symbol = AGSSimpleFillSymbol(style: .solid, color: self.greenAreaColor, outline: .none)
                    graphic = AGSGraphic(geometry: geometry, symbol: symbol, attributes: nil)
                    
                    self.serviceAreaLayer.graphics.add(graphic)
                    
                    self.mapView.setViewpointGeometry(geometry!, padding: 10, completion: nil)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        
        alertController.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil ))
       
        self.present(alertController, animated: true, completion: nil)

    }
    
    private func serviceArea(param: NTServiceAreaParameter) {
        
    }
    
    
    //MARK: Layer delegate
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        mapView.locationDisplay.start(completion: nil)
        
        let env = AGSEnvelope(xMin: 10458701.000000, yMin: 542977.875000,
                              xMax: 11986879.000000, yMax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator())
        mapView.setViewpointGeometry(env, completion: nil)
        
        mapView.graphicsOverlays.add(serviceAreaLayer)
        mapView.graphicsOverlays.add(graphicLayer)

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
                        let cred = AGSCredential(token: token, referer: referrer)
                        let layer = AGSArcGISTiledLayer.init(url: localUrl)
                        layer.credential = cred
                        layer.name = name
                        
                        mapView.map = AGSMap.init(basemap: AGSBasemap.init(baseLayer: layer))
                        mapView.layerViewStateChangedHandler = { (layer, state) in
                            guard layer.loadStatus == .loaded else { return }
                            self.mapViewDidLoad(self.mapView)
                        }
                    }
                }
            }
        }
        catch let error as NSError {
            print("error: \(error)")
        }
    }
    
}
