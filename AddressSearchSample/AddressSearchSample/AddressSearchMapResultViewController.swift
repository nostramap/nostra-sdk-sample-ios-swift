//
//  AddressSearchMapResultViewController.swift
//  AddressSearchSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK
import ArcGIS

class AddressSearchMapResultViewController: UIViewController, AGSCalloutDelegate  {

    let referrer = ""
    
    @IBOutlet weak var mapView: AGSMapView!
    var result: NTAddressSearchResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMap()
    }
    
    //MARK: Callout delegate
    func callout(_ callout: AGSCallout, willShowAtMapPoint mapPoint: AGSPoint) -> Bool {
        if let houseNumber = result?.houseNumber, let soiName = result?.localSoiName {
            callout.title = "\(houseNumber), \(soiName)"
        }
        
        if let admin3Name = result?.adminLevel3?.localName, let admin2Name = result?.adminLevel2?.localName,
            let admin1Name = result?.adminLevel1?.localName {
            callout.detail = "\(admin3Name), \(admin2Name), \(admin1Name)"
        }
        
        return true
    }
    
    func layerDidLoad(_ layer: AGSLayer!) {
        guard let result = self.result, let locPoint = result.locationPoint else { return }
        let point = AGSPoint(x: locPoint.longitude!, y: locPoint.latitude!, spatialReference: AGSSpatialReference.wgs84())
        mapView.setViewpointCenter(point, scale: 10000, completion: nil)
        let graphicLayer = AGSGraphicsOverlay()
        mapView.graphicsOverlays.add(graphicLayer)
        
        let symbol = AGSPictureMarkerSymbol.init(image: UIImage.init(named: "pin_map")!)
        let graphic = AGSGraphic(geometry: point, symbol: symbol, attributes: nil)
        graphicLayer.graphics.add(graphic)
        
        DispatchQueue.main.async {
            self.mapView.callout.show(for: graphic, tapLocation: point, animated: true)
        }
    }
    
    func initializeMap() {
        
        mapView.callout.delegate = self
        
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
                guard layer.loadStatus == .loaded else { return }
                self.layerDidLoad(layer)
            }
            
        } catch let error as NSError {
            print("error: \(error)")
        }
    }
}
