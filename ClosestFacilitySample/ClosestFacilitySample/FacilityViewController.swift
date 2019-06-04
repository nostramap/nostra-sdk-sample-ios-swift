//
//  ViewController.swift
//  ClosestFacilitySample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import ArcGIS
import NOSTRASDK
class FacilityViewController: UIViewController, AGSCalloutDelegate , AGSGeoViewTouchDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    
    let referrer = ""
    
    let graphicLayer = AGSGraphicsOverlay()
    let facilityLayer = AGSGraphicsOverlay()
    
    var idenResult: NTIdentifyResult?
    
    let facility1 = NTLocation(name: "MBK", latitude: 13.744651781616076, longitude: 100.52989481845307)
    let facility2 = NTLocation(name: "SiamDis", latitude: 13.746598089591219, longitude: 100.53145034771327)
    let facility3 = NTLocation(name: "SiamCenter", latitude: 13.746321783330115, longitude: 100.53279034433699)
    let facility4 = NTLocation(name: "SiamParagon", latitude: 13.746155248206387, longitude: 100.53481456769379)
    
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
    func geoView(_ geoView: AGSGeoView, didLongPressAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Pin Location", style: .default) {
            (alert) in
            
            self.facilityLayer.graphics.removeAllObjects()
            
            let graphic = AGSGraphic(geometry: mapPoint,
                                     symbol: AGSPictureMarkerSymbol(image: UIImage(named: "pin_map")!),
                                     attributes: nil)
            
            self.facilityLayer.graphics.add(graphic)
            
            let coordinate2D = mapPoint.toCLLocationCoordinate2D()
            
            let incident = NTLocation(name: "Incident", latitude: coordinate2D.latitude, longitude: coordinate2D.longitude)
            let facilities = [self.facility1, self.facility2, self.facility3, self.facility4]
            let param = NTClosestFacilityParameter(facilities: facilities, incident: incident)
            
            do {
                param.cutOff = 60
                let result = try NTClosestFacilityService.execute(param)
                let lineSymbol = AGSSimpleLineSymbol(style: .solid , color: UIColor.lightGray, width: 4)
                
                for facility in result.closestFacilities! {
                    
                    let geometryRaw =  try AGSGeometry.fromJSON(facility.shape!) as! AGSPolyline
                    let geometry = AGSGeometryEngine.projectGeometry(geometryRaw, to: .wgs84())
                    let graphic = AGSGraphic(geometry: geometry, symbol: lineSymbol, attributes: nil)
                    self.facilityLayer.graphics.add(graphic)
                }
            }
            catch let error as NSError {
                print("error: \(error.description)")
            }
            
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    //MARK: Layer delegate
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        mapView.locationDisplay.start(completion: nil)
        
        let env = AGSEnvelope(xMin: 10458701.000000, yMin: 542977.875000,
                              xMax: 11986879.000000, yMax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator())
        mapView.setViewpointGeometry(env, completion: nil)
        
        mapView.graphicsOverlays.add(facilityLayer)
        mapView.graphicsOverlays.add(graphicLayer)
        
        var graphics = [AGSGraphic]()
        var geometries = [AGSGeometry]()
        
        let compSymbol = AGSCompositeSymbol()
        let textSymbol  = AGSTextSymbol(text: "1", color: UIColor.black, size: 16 , horizontalAlignment: .center, verticalAlignment: .middle)
        let circleSymbol = AGSSimpleMarkerSymbol(style: .circle , color: UIColor.white, size: 30 )
        
        circleSymbol.outline = AGSSimpleLineSymbol(style: .solid , color:  UIColor.black, width: 2 )
        compSymbol.symbols.append(contentsOf: [circleSymbol, textSymbol])
        
        if let point = facility1.point, let symbol = compSymbol.copy() as? AGSSymbol {
            let facilityPoint1 = AGSPoint(x: point.longitude!, y: point.latitude!,
                                          spatialReference: AGSSpatialReference.wgs84())
            let graphic = AGSGraphic(geometry: facilityPoint1 , symbol: symbol, attributes: nil)
            graphics.append(graphic)
            geometries.append(facilityPoint1)
            
        }
        if let point = facility2.point, let symbol = compSymbol.copy() as? AGSSymbol {
            let facilityPoint2 = AGSPoint(x: point.longitude!, y: point.latitude!,
                                          spatialReference: AGSSpatialReference.wgs84())
            let graphic = AGSGraphic(geometry: facilityPoint2, symbol: symbol, attributes: nil)
            graphics.append(graphic)
            geometries.append(facilityPoint2)
            
        }
        if let point = facility3.point, let symbol = compSymbol.copy() as? AGSSymbol {
            let facilityPoint3 = AGSPoint(x: point.longitude!, y: point.latitude!,
                                          spatialReference: AGSSpatialReference.wgs84())
            let graphic = AGSGraphic(geometry: facilityPoint3, symbol: symbol, attributes: nil)
            graphics.append(graphic)
            geometries.append(facilityPoint3)
            
        }
        if let point = facility4.point, let symbol = compSymbol.copy() as? AGSSymbol {
            let facilityPoint4 = AGSPoint(x: point.longitude!, y: point.latitude!,
                                          spatialReference: AGSSpatialReference.wgs84())
            let graphic = AGSGraphic(geometry: facilityPoint4, symbol: symbol, attributes: nil)
            graphics.append(graphic)
            geometries.append(facilityPoint4)
            
        }
        graphicLayer.graphics.addObjects(from: graphics)
        
        //find envelope
        let envGeo = AGSGeometryEngine.unionGeometries(geometries)
        mapView.setViewpointGeometry(envGeo!, completion: nil)
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
        catch let error {
            print("error: \(error.localizedDescription)")
        }
    }
    
}
