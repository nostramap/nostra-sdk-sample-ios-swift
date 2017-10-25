//
//  ViewController.swift
//  IdentifySample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK
import ArcGIS
class IdentifyViewController: UIViewController, AGSMapViewLayerDelegate, AGSMapViewTouchDelegate, AGSLayerDelegate, AGSCalloutDelegate {

    @IBOutlet weak var mapView: AGSMapView!
    
    let referrer = ""
    
    let graphicLayer = AGSGraphicsLayer();
    var idenResult: NTIdentifyResult?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeMap();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let detailViewController = segue.destination as! DetailViewController;
            detailViewController.idenResult = idenResult;
            
        }
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
        catch let error as NSError {
            print("error: \(error)");
        }
    }
    
    @IBAction func btnCurrentLocation_Clicked(_ btn: UIButton) {
        
        btn.isSelected = !btn.isSelected;
        mapView.locationDisplay.autoPanMode = btn.isSelected ? .default : .off;
        
    }
    

    //MARK: Touch Delegate
    func mapView(_ mapView: AGSMapView!, didTapAndHoldAt screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [AnyHashable: Any]!) {
        
        
        if graphicLayer.graphicsCount > 0 {
            graphicLayer.removeAllGraphics();
        }
        
        let symbol = AGSSimpleMarkerSymbol(color: UIColor.red);
        symbol?.style = .X;
        symbol?.size = CGSize(width: 15, height: 15);
        
        let graphic = AGSGraphic(geometry: mappoint, symbol: symbol, attributes: nil);
        
        graphicLayer.addGraphic(graphic);
        
    }
    
    //MARK: Callout delegate
    func callout(_ callout: AGSCallout!, willShowFor feature: AGSFeature!, layer: AGSLayer!, mapPoint: AGSPoint!) -> Bool {
        
        var show = false
        
        let decString = mapPoint.decimalDegreesString(withNumDigits: 7)
        
        if let point = AGSPoint(fromDecimalDegreesString: decString, with: AGSSpatialReference.wgs84()) {
            
            let idenParam = NTIdentifyParameter(latitude: point.y, longitude: point.x)
            
            if let result = try? NTIdentifyService.execute(idenParam) {
                callout.title = result.localName
                
                if let admin1 = result.adminLevel1?.localName, let admin2 = result.adminLevel2?.localName, let admin3 = result.adminLevel3?.localName {
                    callout.detail = "\(admin3), \(admin2), \(admin1)"
                }
                
                if result.nostraId != nil && result.nostraId != "" {
                    callout.accessoryButtonType = .detailDisclosure
                    callout.isAccessoryButtonHidden = false;
                }
                else {
                    callout.isAccessoryButtonHidden = true;
                }
                
                self.idenResult = result
                
                show = true
            }
        }
        
        return show;
    }

    func didClickAccessoryButton(for callout: AGSCallout!) {
        self.performSegue(withIdentifier: "detailSegue", sender: nil);
    }
    
    //MARK: Map view and Layer delegate
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        mapView.locationDisplay.startDataSource()
        
        let env = AGSEnvelope(xmin: 10458701.000000, ymin: 542977.875000,
                              xmax: 11986879.000000, ymax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator());
        mapView.zoom(to: env, animated: true);
        
        mapView.addMapLayer(graphicLayer, withName: "GraphicLyaer");
        
    }

    
    func layerDidLoad(_ layer: AGSLayer!) {
        print("\(layer.name) was loaded");
    }
    
    func layer(_ layer: AGSLayer!, didFailToLoadWithError error: Error!) {
        print("\(layer.name) failed to load by reason: \(error.localizedDescription)");
    }
    
}

