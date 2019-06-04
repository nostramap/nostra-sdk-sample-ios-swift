//
//  ViewController.swift
//  MultiModalSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import ArcGIS
import NOSTRASDK

class MultiModalMainViewController: UIViewController, MarkOnMapDelegate, TravelByDelegate {

    let referrer = ""
    
    @IBOutlet weak var mapView: AGSMapView!
    
    var graphicLayer: AGSGraphicsOverlay! = nil
    
    @IBOutlet weak var btnFromLocation: UIButton!
    @IBOutlet weak var btnToLocation: UIButton!
    
    var toLocation: NTLocation! = nil
    var fromLocation: NTLocation! = nil
    var travels: [NTMultiModalTransportMode]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initializeMap()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is TravelByViewController {
            let travelViewController = segue.destination as! TravelByViewController
            travelViewController.delegate = self
            
        }
        else if segue.destination is MarkOnMapViewController {
            let markOnMapViewController = segue.destination as! MarkOnMapViewController
            let btn = sender as! UIButton
            markOnMapViewController.delegate = self
            markOnMapViewController.isFromLocation = btn.tag == 0
        }
    }
    
    @IBAction func btnCalculate_Clicked(_ sender: AnyObject) {
        if self.travels.count > 0 {
            self.CallMultiModalRoute([fromLocation, toLocation], mode: self.travels)
        }
    }
    
    func CallMultiModalRoute(_ stops: [NTLocation], mode: [NTMultiModalTransportMode]) {
        
        do {

            let param = NTMultiModalTransportParamter(stops: stops, travelModes: mode)
            
            let result = try NTMultiModalTransportService.execute(param)
            var geometry: [AGSGeometry]! = []
            if let directions = result.minute?.directions {
                
                for direction in directions {
                    
                    let geometryRaw = try AGSGeometry.fromJSON(direction.shape) as! AGSPolyline
                    let geo = AGSGeometryEngine.projectGeometry(geometryRaw, to: .wgs84())
                    
                    geometry.append(geo!)
                    
                    let symbol = AGSSimpleLineSymbol.init(style: direction.type == .walk ? .dot : .solid,
                                             color: UIColor(red: direction.type == .walk ? 0.0 : 1.0,
                                                            green: 0,
                                                            blue: direction.type == .walk ? 1.0 : 0.0,
                                                            alpha: direction.type == .walk ? 1.0 : 0.5),
                                             width: 10)
                    
                    let graphic = AGSGraphic(geometry: geo, symbol: symbol, attributes: nil)
                    graphicLayer.graphics.add(graphic)
                    
                }
                
                let uGeo = AGSGeometryEngine.unionGeometries(geometry)
                mapView.setViewpointGeometry(uGeo!, completion: nil)
            }
        }
        catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func didFinishSelectTravelMode(_ travels: [NTMultiModalTransportMode]) {
        self.travels = travels
    }
    
    func didFinishSelectToLocation(_ point: AGSPoint) {
        toLocation = NTLocation(name: "location 2", latitude: point.y, longitude: point.x)
        btnToLocation.setTitle("location 2", for: UIControlState())
        btnToLocation.setTitleColor(UIColor.black, for: UIControlState())
    }
    
    func didFinishSelectFromLocation(_ point: AGSPoint) {
        fromLocation = NTLocation(name: "location 1", latitude: point.y, longitude: point.x)
        btnFromLocation.setTitle("location 1", for: UIControlState())
        btnFromLocation.setTitleColor(UIColor.black, for: UIControlState())
    }
    
    func initializeMap() {

        do {
            // Get map permisson.
            let resultSet = try NTMapPermissionService.execute()
            
            /// Get Street map HD (service id: 2)
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
            print("error: \(error)")
        }
    }
    
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        mapView.locationDisplay.start(completion: nil)
        
        let env = AGSEnvelope(xMin: 10458701.000000, yMin: 542977.875000,
                              xMax: 11986879.000000, yMax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator())
        mapView.setViewpointGeometry(env, completion: nil)
        
        graphicLayer = AGSGraphicsOverlay()
        graphicLayer.overlayID = "GraphicLyaer"
        mapView.graphicsOverlays.add(graphicLayer)
    }
    
    func layerDidLoad(_ layer: AGSLayer!) {
        print("\(layer.name) was loaded")
    }
    
    func layer(_ layer: AGSLayer!, didFailToLoadWithError error: Error!) {
        print("\(layer.name) failed to load by reason: \(String(describing: error))")
    }
}

