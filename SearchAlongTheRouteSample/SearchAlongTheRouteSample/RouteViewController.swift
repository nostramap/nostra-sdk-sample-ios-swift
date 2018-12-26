//
//  ViewController.swift
//  SearchAlongTheRouteSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import ArcGIS
import NOSTRASDK

class RouteViewController: UIViewController, AGSMapViewLayerDelegate, AGSLayerDelegate, MarkOnMapDelegate {

    let referrer = ""
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var lblResult: UILabel!
    
    @IBOutlet weak var btnFromLocation: UIButton!
    @IBOutlet weak var btnToLocation: UIButton!
    
    var fromLocation: NTLocation! = nil;
    var toLocation: NTLocation! = nil;
    
    var vehicle: NTTravelMode = .car;
    
    var result: NTRouteResult?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeMap();
        self.initLocation();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnVehicle_Clicked(_ sender: AnyObject) {
        let btn = sender as? UIButton;
        let alertController = UIAlertController(title: "Vehicle", message: nil, preferredStyle: .actionSheet);
        alertController.addAction(UIAlertAction(title: "Car", style: .default, handler: { (action) in
            self.vehicle = .car;
            btn?.setTitle("Car", for: UIControlState());
        }));
        alertController.addAction(UIAlertAction(title: "Motocycle", style: .default, handler: { (action) in
            self.vehicle = .motorcycle;
            btn?.setTitle("Motocycle", for: UIControlState());
        }));
        alertController.addAction(UIAlertAction(title: "Bike", style: .default, handler: { (action) in
            self.vehicle = .bicycle;
            btn?.setTitle("Bike", for: UIControlState());
        }));
        alertController.addAction(UIAlertAction(title: "Walk", style: .default, handler: { (action) in
            self.vehicle = .walk;
            btn?.setTitle("Walk", for: UIControlState());
        }));
        self .present(alertController, animated: true, completion: nil);
    }
    
    
    @IBAction func btnRoute_Clicked(_ sender: AnyObject) {
        
        if toLocation != nil && fromLocation != nil {
            let param = NTRouteParameter(stops: [fromLocation, toLocation]);
            param.travelMode = vehicle;
            
            do {
                let result = try NTRouteService.execute(param)
                
                let polyline = AGSPolyline(json: result.shape, spatialReference: AGSSpatialReference.wgs84());
                let geometry = AGSGeometryEngine.default().projectGeometry(polyline,
                                                                           to: AGSSpatialReference.webMercator());
                
                self.searchAlongTheRoute(fromPolyline: polyline!);
                
                let graphicLayer = AGSGraphicsLayer();
                mapView.addMapLayer(graphicLayer);
                
                let color = UIColor(red: 63.0/255.0, green: 81.0/255.0, blue: 181.0/255.0, alpha: 1.0);
                let symbol = AGSSimpleLineSymbol(color: color, width: 3.0);
                
                let graphic = AGSGraphic(geometry: geometry, symbol: symbol, attributes: nil);
                
                graphicLayer.addGraphic(graphic);
                
                if let totalTime = result.totalTime, let totalLenght = result.totalLength {
                    lblResult.text = String(format: "%.1f min (%.1f Km.)", totalTime, totalLenght / 1000);
                }
                
                resultView.isHidden = false
                mapView.zoom(to: graphic?.geometry, withPadding: 50, animated: true)
                self.result = result
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            catch let err {
                print(err.localizedDescription)
            }
            
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromLocationSegue" || segue.identifier == "toLocationSegue" {
            let markOnMapViewController = segue.destination as? MarkOnMapViewController;
            markOnMapViewController?.delegate = self;
            markOnMapViewController?.isFromLocation = segue.identifier == "fromLocationSegue";
        }
        else if segue.identifier == "routeDetailSegue" {
            let detailViewController = segue.destination as? RouteDetailViewController;
            detailViewController?.directions = result?.directions;
        }
        else if segue.identifier == "searchSegue" {
            let searchViewController = segue.destination as? SearchViewController
            let directionPoints = self.result?.directions?.filter { $0.point != nil }.map({ (direction) -> NTPoint in
                return direction.point!
            })
            if let points = directionPoints {
                searchViewController?.points = points
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "searchSegue" {
            if let directionPoints = self.result?.directions?.filter({ $0.point != nil }), directionPoints.count > 0 {
                return true
            }
            else {
                return false
            }
        }
        else {
            return true
        }
    }
    
    func initLocation() {
        fromLocation = NTLocation(name: "location 1", latitude: 13.722556, longitude: 100.530643);
        btnFromLocation.setTitleColor(UIColor.black, for: UIControlState());
        btnFromLocation.setTitle(fromLocation.name, for: .normal);
        
        toLocation = NTLocation(name: "location 2", latitude: 13.768231, longitude: 100.540044)
        btnToLocation.setTitleColor(UIColor.black, for: UIControlState());
        btnToLocation.setTitle(toLocation.name, for: .normal);
    }

    func didFinishSelectToLocation(_ point: AGSPoint) {
        
        let decString = point.decimalDegreesString(withNumDigits: 7)
        if let llPoint = AGSPoint(fromDecimalDegreesString: decString, with: AGSSpatialReference.wgs84()) {
            toLocation = NTLocation(name: "location 2", latitude: llPoint.y, longitude: llPoint.x)
            btnToLocation.setTitleColor(UIColor.black, for: UIControlState());
            btnToLocation.setTitle(toLocation.name, for: .normal);
        }
    }
    
    func didFinishSelectFromLocation(_ point: AGSPoint) {
        let decString = point.decimalDegreesString(withNumDigits: 7)
        if let llPoint = AGSPoint(fromDecimalDegreesString: decString, with: AGSSpatialReference.wgs84()) {
            fromLocation = NTLocation(name: "location 1", latitude: llPoint.y, longitude: llPoint.x);
            btnFromLocation.setTitleColor(UIColor.black, for: UIControlState());
            btnFromLocation.setTitle(fromLocation.name, for: .normal);
        }
    }
    

    func initializeMap() {
        
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
    
    //MARK: Map view and Layer delegate
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        mapView.locationDisplay.startDataSource()
        
        let env = AGSEnvelope(xmin: 10458701.000000, ymin: 542977.875000,
                              xmax: 11986879.000000, ymax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator());
        mapView.zoom(to: env, animated: true);
    }
    
    func layerDidLoad(_ layer: AGSLayer!) {
        print("\(layer.name) was loaded");
    }
    
    func layer(_ layer: AGSLayer!, didFailToLoadWithError error: Error!) {
        print("\(layer.name) failed to load by reason: \(error)");
    }
    
    func searchAlongTheRoute(fromPolyline: AGSPolyline) {
        let pointCount = fromPolyline.numPoints(inPath: 0) - 1;
        var points = [NTPoint]();
        
        for pointIdx in 0...pointCount {
            let p = fromPolyline.point(onPath: 0, at: pointIdx)
            let point = NTPoint(latitude: (p?.y)!, longitude: (p?.x)!);
            points.append(point);
        }
        
        // Specify Categories Code
        let catCodes = ["FUEL-OIL"]; //User array if need multiple categories code
        
        let param = NTSearchAlongRouteParameter(points: points, searchType: NTSearchAlongRouteType.searchForNearbyPlaces, categoryCodes: catCodes);
        
        param.buffer = 0.6; //Kilometer
        
        do {
            let result = try NTSearchAlongRouteService.execute(param);
            
            if ((result.results?.count)! > 0) {
                //Print result from SearchAlongTheRoute
                let graphicLayer = AGSGraphicsLayer();
                for poi in result.results! {
                    let gisPoint = AGSPoint(x: (poi.locationPoint?.longitude)!, y: (poi.locationPoint?.latitude)!, spatialReference: AGSSpatialReference.wgs84());
                    let geometry = AGSGeometryEngine.default().projectGeometry(gisPoint,
                                                                               to: AGSSpatialReference.webMercator());
                    let symbol = AGSPictureMarkerSymbol(imageNamed: "pin_map");
                    let graphic = AGSGraphic(geometry: geometry, symbol: symbol, attributes: nil);
                    graphicLayer.addGraphic(graphic);
                }
                mapView.addMapLayer(graphicLayer);
            }
        }
        catch let err {
            print(err.localizedDescription)
        }
    }
}

