//
//  ViewController.swift
//  ClosestFacilitySample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import ArcGIS
import NOSTRASDK
class FacilityViewController: UIViewController, AGSMapViewLayerDelegate, AGSMapViewTouchDelegate, AGSCalloutDelegate, AGSLayerDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    
    let referrer = ""
    
    let graphicLayer = AGSGraphicsLayer();
    let facilityLayer = AGSGraphicsLayer();

    var idenResult: NTIdentifyResult?;
    
    let facility1 = NTLocation(name: "MBK", latitude: 13.744651781616076, longitude: 100.52989481845307)
    let facility2 = NTLocation(name: "SiamDis", latitude: 13.746598089591219, longitude: 100.53145034771327)
    let facility3 = NTLocation(name: "SiamCenter", latitude: 13.746321783330115, longitude: 100.53279034433699)
    let facility4 = NTLocation(name: "SiamParagon", latitude: 13.746155248206387, longitude: 100.53481456769379)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initializeMap();
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnCurrentLocation_Clicked(_ btn: UIButton) {
        
        btn.isSelected = !btn.isSelected;
        mapView.locationDisplay.autoPanMode = btn.isSelected ? .default : .off;
        
    }
    
    
    //MARK: Touch Delegate
    func mapView(_ mapView: AGSMapView!, didClickAt screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [AnyHashable: Any]!) {
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        alertController.addAction(UIAlertAction(title: "Pin Location", style: .default) {
            (alert) in
            
            self.facilityLayer.removeAllGraphics();
            
            let graphic = AGSGraphic(geometry: mappoint,
                symbol: AGSPictureMarkerSymbol(imageNamed: "pin_map"),
                attributes: nil);
            
            self.facilityLayer.addGraphic(graphic)
            
            let decString = mappoint.decimalDegreesString(withNumDigits: 7)
            guard let point = AGSPoint(fromDecimalDegreesString: decString, with: AGSSpatialReference.wgs84()) else {
                return
            }
            
            let incident = NTLocation(name: "Incident", latitude: point.y, longitude: point.x)
            let facilities = [self.facility1, self.facility2, self.facility3, self.facility4];
            let param = NTClosestFacilityParameter(facilities: facilities, incident: incident)

            do {
                param.cutOff = 60
                let result = try NTClosestFacilityService.execute(param)
                
                let lineSymbol = AGSSimpleLineSymbol(color: UIColor.lightGray,width: 4);
                
                for facility in result.closestFacilities! {
                    
                    let line = AGSPolyline(json: facility.shape,
                                           spatialReference: AGSSpatialReference.wgs84())
                    let geometry = AGSGeometryEngine.default().projectGeometry(line, to: AGSSpatialReference.webMercator())
                    let graphic = AGSGraphic(geometry: geometry, symbol: lineSymbol, attributes: nil);
                    self.facilityLayer.addGraphic(graphic);
                }

            }
            catch let error as NSError {
                print("error: \(error.description)");
            }
         
            });
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil);
        
    }
    
    
    //MARK: Layer delegate
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        mapView.locationDisplay.startDataSource()
        
        let env = AGSEnvelope(xmin: 10458701.000000, ymin: 542977.875000,
                              xmax: 11986879.000000, ymax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator());
        mapView.zoom(to: env, animated: true);
        
        mapView.addMapLayer(facilityLayer);
        mapView.addMapLayer(graphicLayer);
        
        var graphics = [AGSGraphic]()
        var geometries = [AGSGeometry]()
        
        let compSymbol = AGSCompositeSymbol()
        let textSymbol  = AGSTextSymbol(text: "1", color: UIColor.black)!
        let circleSymbol = AGSSimpleMarkerSymbol(color: UIColor.white)!
        
        circleSymbol.outline = AGSSimpleLineSymbol(color: UIColor.black, width: 2.0);
        circleSymbol.size = CGSize(width: 30, height: 30)
        
        compSymbol.addSymbols([circleSymbol, textSymbol])
        
        if let point = facility1.point, let symbol = compSymbol.copy() as? AGSSymbol {
            let facilityPoint1 = AGSPoint(x: point.longitude!, y: point.latitude!,
                                          spatialReference: AGSSpatialReference.wgs84())
            if let decString = facilityPoint1?.decimalDegreesString(withNumDigits: 7) {
                let mappoint = AGSPoint(fromDecimalDegreesString: decString,
                                          with: AGSSpatialReference.webMercator())
                
                if let graphic = AGSGraphic(geometry: mappoint, symbol: symbol, attributes: nil) {
                    graphics.append(graphic)
                    geometries.append(mappoint!)
                }
                
            }
            
            
        }
        if let point = facility2.point, let symbol = compSymbol.copy() as? AGSSymbol {
            let facilityPoint2 = AGSPoint(x: point.longitude!, y: point.latitude!,
                                          spatialReference: AGSSpatialReference.wgs84())
            if let decString = facilityPoint2?.decimalDegreesString(withNumDigits: 7) {
                textSymbol.text = "2";
                let mappoint = AGSPoint(fromDecimalDegreesString: decString,
                                        with: AGSSpatialReference.webMercator())
                
                if let graphic = AGSGraphic(geometry: mappoint, symbol: symbol, attributes: nil) {
                    graphics.append(graphic)
                    geometries.append(mappoint!)
                }
            }
        }
        if let point = facility3.point, let symbol = compSymbol.copy() as? AGSSymbol {
            let facilityPoint3 = AGSPoint(x: point.longitude!, y: point.latitude!,
                                          spatialReference: AGSSpatialReference.wgs84())
            if let decString = facilityPoint3?.decimalDegreesString(withNumDigits: 7) {
                textSymbol.text = "3"
                let mappoint = AGSPoint(fromDecimalDegreesString: decString,
                                        with: AGSSpatialReference.webMercator())
                
                if let graphic = AGSGraphic(geometry: mappoint, symbol: symbol, attributes: nil) {
                    graphics.append(graphic)
                    geometries.append(mappoint!)
                }
            }
        }
        if let point = facility4.point, let symbol = compSymbol.copy() as? AGSSymbol {
            let facilityPoint4 = AGSPoint(x: point.longitude!, y: point.latitude!,
                                          spatialReference: AGSSpatialReference.wgs84())
            if let decString = facilityPoint4?.decimalDegreesString(withNumDigits: 7) {
                textSymbol.text = "4";
                let mappoint = AGSPoint(fromDecimalDegreesString: decString,
                                        with: AGSSpatialReference.webMercator())
                
                if let graphic = AGSGraphic(geometry: mappoint, symbol: symbol, attributes: nil) {
                    graphics.append(graphic)
                    geometries.append(mappoint!)
                }
            }
        }
        graphicLayer.addGraphics(graphics);
        
        //find envelope
        let envGeo = AGSGeometryEngine.default().unionGeometries(geometries);
        mapView.zoom(to: envGeo, withPadding: 100, animated: true);
        
    }
    
    func initializeMap() {
        
        mapView.layerDelegate = self;
        mapView.touchDelegate = self;
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
        catch let error {
            print("error: \(error.localizedDescription)");
        }
    }
    
}
