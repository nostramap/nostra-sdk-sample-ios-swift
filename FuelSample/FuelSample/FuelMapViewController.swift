//
//  FuelMapViewController.swift
//  FuelSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK
import ArcGIS

class FuelMapViewController: UIViewController {
    
    let referrer = ""

    @IBOutlet weak var mapView: AGSMapView!
    
    @IBOutlet var btnOk: UIButton!
    
    
    var isFromLocation = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        initializeMap()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultSegue" {
            let point = mapView.screen(toLocation: mapView.center).toCLLocationCoordinate2D()
            let resultViewController = segue.destination as? FuelResultVendorViewController
            resultViewController?.latitude = point.latitude
            resultViewController?.longitude = point.longitude
        }
    }
    
    
    @IBAction func btnOk_Clicked(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "resultSegue", sender: nil)
        
    }
    
    
    func initializeMap() {

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
            mapView.layerViewStateChangedHandler = { (layer, state) in
                if layer.loadStatus == .loaded {
                    self.layerDidLoad(layer)
                } else {
                    self.layer(layer, didFailToLoadWithError: layer.loadError)
                }
            }
            
        } catch let error as NSError {
            print("error: \(error)")
        }
    }
    
    func layerDidLoad(_ layer: AGSLayer!) {
        print("\(layer.name) was loaded")
    }
    
    func layer(_ layer: AGSLayer!, didFailToLoadWithError error: Error!) {
        print("\(layer.name) failed to load by reason: \(String(describing: error))")
    }
}
