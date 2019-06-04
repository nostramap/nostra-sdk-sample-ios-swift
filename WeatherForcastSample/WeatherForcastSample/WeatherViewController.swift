//
//  ViewController.swift
//  WeatherForcastSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK
import ArcGIS

class WeatherViewController: UIViewController , AGSCalloutDelegate, AGSGeoViewTouchDelegate {
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
    
    let graphicLayer = AGSGraphicsOverlay()
    var weatherResult: NTWeatherResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeMap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Touch Delegate
    func geoView(_ geoView: AGSGeoView, didLongPressAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        if graphicLayer.graphics.count > 0 {
            graphicLayer.graphics.removeAllObjects()
        }
        
        let symbol = AGSPictureMarkerSymbol(image: UIImage(named: "pin_map")!)
        let graphic = AGSGraphic(geometry: mapPoint, symbol: symbol, attributes: nil)
        
        graphicLayer.graphics.add(graphic)
        mapView.callout.show(for: graphic, tapLocation: mapPoint, animated: true)
    }

    //MARK: Callout delegate
    func callout(_ callout: AGSCallout, willShowAtMapPoint mapPoint: AGSPoint) -> Bool {
        do {
            let coordinate2D = mapPoint.toCLLocationCoordinate2D()
            
            let param = NTWeatherParameter(latitude: coordinate2D.latitude, longitude: coordinate2D.longitude, frequency: .daily)
            
            weatherResult = try NTWeatherService.execute(param)
            
            if let locName = weatherResult?.locationName, let weather = weatherResult?.weather?.first {
                lblLocation.text = locName
                
                if let url = weather.iconUrl, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    callout.image = image
                    callout.isAccessoryButtonHidden = true
                    imageView.image = image
                }
                lblDesc.text = weather.weatherDescription
                if let avg = weather.temperature?.average, let min = weather.temperature?.min, let max = weather.temperature?.max {
                    lblAvgTemp.text = String(format: "%1.f˚", avg)
                    lblMinTemp.text =  String(format: "%1.f˚", min)
                    lblMaxTemp.text =  String(format: "%1.f˚", max)
                }
                
                if let dt = weather.datetime {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd MMM hh:mm"
                    lblDateTime.text = formatter.string(from: dt)
                }
                weatherView.isHidden = false
            }
            callout.isAccessoryButtonHidden = true
        }
        catch let error as NSError {
            print("error: \(error.description)")
        }
        return true
    }
    
    //MARK: Layer delegate
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        // mapView.locationDisplay.startDataSource()
        mapView.locationDisplay.start(completion: nil)
        
        let env = AGSEnvelope(xMin: 10458701.000000, yMin: 542977.875000,
                              xMax: 11986879.000000, yMax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator())
        mapView.setViewpointGeometry(env, completion: nil)
        graphicLayer.overlayID = "GraphicLyaer"
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

                        //TODO: remove credential
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
