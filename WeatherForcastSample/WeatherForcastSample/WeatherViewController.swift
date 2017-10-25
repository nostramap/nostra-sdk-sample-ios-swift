//
//  ViewController.swift
//  WeatherForcastSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK
import ArcGIS

class WeatherViewController: UIViewController, AGSMapViewLayerDelegate, AGSMapViewTouchDelegate, AGSCalloutDelegate, AGSLayerDelegate {
    
    let referrer = ""
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var lblMaxTemp: UILabel!
    @IBOutlet weak var lblMinTemp: UILabel!
    @IBOutlet weak var lblAvgTemp: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!

    let graphicLayer = AGSGraphicsLayer();
    var weatherResult: NTWeatherResult?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initializeMap();
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: Touch Delegate
    func mapView(_ mapView: AGSMapView!, didTapAndHoldAt screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [AnyHashable: Any]!) {
        
        
        if graphicLayer.graphicsCount > 0 {
            graphicLayer.removeAllGraphics();
        }
        
        let symbol = AGSPictureMarkerSymbol(imageNamed: "pin_map");
        
        let graphic = AGSGraphic(geometry: mappoint, symbol: symbol, attributes: nil);
        
        graphicLayer.addGraphic(graphic);
        
        
        mapView.callout.show(at: mappoint, for: graphic, layer: graphicLayer, animated: true);
    }
    
    //MARK: Callout delegate
    func callout(_ callout: AGSCallout!, willShowFor feature: AGSFeature!, layer: AGSLayer!, mapPoint: AGSPoint!) -> Bool {
        
        do {
            let point = AGSPoint(fromDecimalDegreesString: mapPoint.decimalDegreesString(withNumDigits: 7),
                                 with: AGSSpatialReference.wgs84());
            

            let param = NTWeatherParameter(latitude: point!.y, longitude: point!.x, frequency: .daily);
            
            weatherResult = try NTWeatherService.execute(param);
            
            
            if let locName = weatherResult?.locationName, let weather = weatherResult?.weather?.first {
                lblLocation.text = locName
                
                if let url = weather.iconUrl, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    callout.image = image
                    callout.isAccessoryButtonHidden = true
        
                    imageView.image = image
                }
                
                
                
                lblDesc.text = weather.weatherDescription
                if let avg = weather.temperature?.average, let min = weather.temperature?.min, let max = weather.temperature?.max {
                    lblAvgTemp.text = String(format: "%1.f˚", avg);
                    lblMinTemp.text =  String(format: "%1.f˚", min);
                    lblMaxTemp.text =  String(format: "%1.f˚", max);
                }
                
                if let dt = weather.datetime {
                    let formatter = DateFormatter();
                    formatter.dateFormat = "dd MMM hh:mm";
                    lblDateTime.text = formatter.string(from: dt);
                }
                weatherView.isHidden = false;
            }
            
            
            callout.isAccessoryButtonHidden = true;
            
            
        }
        catch let error as NSError {
            print("error: \(error.description)")
        }
        
        
        
        return true;
    }
    
    func didClickAccessoryButton(for callout: AGSCallout!) {
        self.performSegue(withIdentifier: "detailSegue", sender: nil);
    }
    
    //MARK: Layer delegate
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        mapView.locationDisplay.startDataSource()
        
        let env = AGSEnvelope(xmin: 10458701.000000, ymin: 542977.875000,
                              xmax: 11986879.000000, ymax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator());
        mapView.zoom(to: env, animated: true);
        
        mapView.addMapLayer(graphicLayer, withName: "GraphicLyaer");
        
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
    
}
