//
//  ViewController.swift
//  MapSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import ArcGIS
import NOSTRASDK

class MapViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var btnHide: UIButton!
    
    @IBOutlet weak var tableViewLeading: NSLayoutConstraint!

    let referrer = "" // Set your map referrer
    
    var mapResultSet: NTMapPermissionResultSet?
    var basemaps:[NTMapPermissionResult] = []
    var layers:[NTMapPermissionResult] = []
    var selectedBasemap: IndexPath?
    var selectedLayer: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.map = AGSMap.init()
        
        do {

            mapResultSet = try NTMapPermissionService.execute()
            
            if let results = mapResultSet?.results, results.count > 0{
                
                let mapResultSetSorted = results.sorted(by: { (aService, bService) -> Bool in
                    return aService.sortedIndex < bService.sortedIndex
                })
                
                for mapPermission in mapResultSetSorted {

                    if mapPermission.layerType == .basemap || mapPermission.layerType == .imagery {
                        basemaps.append(mapPermission)
                    } else {
                        layers.append(mapPermission)
                    }
                    
                    if mapPermission.serviceId == 2 {
                        self.addLayer(mapPermission)
                    }
                    else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            // your function here
                            self.addLayer(mapPermission)
                        }
                    }
                }
            }
            
            mapView.map?.load(completion: { (error) in
                guard error == nil else { print(error!.localizedDescription); return }
                self.mapViewDidLoad(self.mapView)
            })
            
            mapView.layerViewStateChangedHandler = { (layer, state) in
                if layer.loadStatus == .loaded {
                    self.layerDidLoad(layer)
                } else if layer.loadStatus == .failedToLoad {
                    self.layer(layer, didFailToLoadWithError: layer.loadError)
                }
            }
            
        } catch let error as NSError {
            print("error: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addLayer(_ mapPermission: NTMapPermissionResult) {
        
        var layer: AGSLayer! = nil
        
        guard let url = mapPermission.localService?.url else { return }

        if mapPermission.mapServiceType == .tiledMapService {
            
            let tiledLyr = AGSArcGISTiledLayer.init(url: url)
            
            if let token = mapPermission.localService?.token, !token.isEmpty {
                let cred = AGSCredential(token: token, referer: referrer)
                tiledLyr.credential = cred
            }
            
            tiledLyr.maxScale = 0
            layer = tiledLyr
            
        } else if mapPermission.mapServiceType == .dynamicMapService {
            
            let dynamicLyr = AGSArcGISMapImageLayer.init(url: url)
            
            if let token = mapPermission.localService?.token, !token.isEmpty {
                let cred = AGSCredential(token: token, referer: referrer)
                dynamicLyr.credential = cred
            }
            
            layer = dynamicLyr

        } else if mapPermission.mapServiceType == .featureService {
            
            var featLayer: AGSFeatureLayer?
            
            let featureTable = AGSServiceFeatureTable.init(url: url)
            
            if let token = mapPermission.localService?.token, !token.isEmpty {
                let cred = AGSCredential(token: token, referer: referrer)
                featureTable.credential = cred
            }
            
            featLayer = AGSFeatureLayer.init(featureTable: featureTable)
            featLayer?.renderingMode = .static
            
            layer = featLayer
            
        } else if mapPermission.mapServiceType == .webMapService {
            let wmsLayer = AGSWMSLayer(url: url, layerNames: [mapPermission.name ?? ""])
            
            if let token = mapPermission.localService?.token, !token.isEmpty {
                let cred = AGSCredential(token: token, referer: referrer)
                wmsLayer.credential = cred
            }
            
            layer = wmsLayer
        } else if mapPermission.mapServiceType == .openSteetMap {
            layer = AGSOpenStreetMapLayer()
        } else if mapPermission.mapServiceType == .vectorTiledMapService {
            let vectorTiledLayer = AGSArcGISVectorTiledLayer(url: url)
            
            if let token = mapPermission.localService?.token, !token.isEmpty {
                let cred = AGSCredential(token: token, referer: referrer)
                vectorTiledLayer.credential = cred
            }
            
            layer = vectorTiledLayer
        }

        if layer != nil, let name = mapPermission.name {
            // layer will be visibled, if service id is 2 (Street map Thailand HD).
            layer.isVisible = mapPermission.serviceId == 2
            
            layer.name = name
            
            mapView.map?.operationalLayers.add(layer)
            
        } else {
            print("error to intialize layer: \(mapPermission.name ?? "")")
        }
    }
    
    
    func showMenu() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        tableViewLeading.constant = 0
        self.view.layoutIfNeeded()
        UIView.commitAnimations()
        btnHide.isHidden = false
    }
    
    func hideMenu() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        tableViewLeading.constant = -260
        self.view.layoutIfNeeded()
        UIView.commitAnimations()
        btnHide.isHidden = true
    }
    
    //MARK: UI events
    @IBAction func btnMapLayer_Clicked() {
        showMenu()
    }
    
    @IBAction func btnHide_Clicked() {
        hideMenu()
    }
    
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        
        mapView.locationDisplay.start(completion: nil)
        
        let env = AGSEnvelope(xMin: 10458701.000000, yMin: 542977.875000,
                              xMax: 11986879.000000, yMax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator())
        
        mapView.setViewpointGeometry(env, completion: nil)

    }
    
    func layerDidLoad(_ layer: AGSLayer!) {
        print("\(layer.name) was loaded")
    }
    
    func layer(_ layer: AGSLayer!, didFailToLoadWithError error: Error!) {
        print("\(layer.name) failed to load by reason: \(String(describing: error))")
        // remove layer, if it fail to load.
        mapView.map?.operationalLayers.remove(layer)
    }
    
    //MARK: Layer management
    func visibleLayer(_ visible: Bool, serviceId: Int) {
        
        if let results = mapResultSet?.results, results.count > 0 {
            
            /// Find map
            let filtered = results.filter({ (mp) -> Bool in
                return mp.serviceId == serviceId
            })
            
            if let mapPermission = filtered.first, let name = mapPermission.name {
                
                for layerObject in mapView.map!.operationalLayers {
                    guard let layer = layerObject as? AGSLayer else { continue }
                    guard layer.name == name else { continue }
                    layer.isVisible = visible
                }
                
                let dependMap : [Int] = mapPermission.dependMap
                // Manage depend map visible
                if  (dependMap.count > 0) {
                    for mapId in dependMap {
                        self.visibleLayer(visible, serviceId: mapId)
                    }
                }
            }
        }
    }
    
    func findServiceId(_ serviceName: String) -> Int? {
        
        var mapPermission: NTMapPermissionResult?
        
        if let results = mapResultSet?.results, results.count > 0 {
            /// Find map
            let filtered = results.filter({ (mp) -> Bool in
                return mp.name == serviceName
            })
            
            mapPermission = filtered.first
            
        }
        
        return mapPermission?.serviceId
        
    }
    
    //MARK: Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == 0 {

            if selectedBasemap != nil {
                tableView.deselectRow(at: selectedBasemap!, animated: false)
                self.visibleLayer(false, serviceId: basemaps[(selectedBasemap?.row)!].serviceId)
            }
            selectedBasemap = indexPath
            
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        
        let serviceId = self.findServiceId((cell?.textLabel?.text)!)
        
        if serviceId != nil {
            self.visibleLayer(true, serviceId: serviceId!)
        }
        
        self.hideMenu()
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == 1 {
            let cell = tableView.cellForRow(at: indexPath)
            
            let serviceId = self.findServiceId((cell?.textLabel?.text)!)
            
            if serviceId != nil {
                self.visibleLayer(false, serviceId: serviceId!)
            }
        }
        self.hideMenu()
        
    }
    
    @IBAction func btnLocLocation_Clicked(_ sender: AnyObject) {
        
        mapView.locationDisplay.autoPanMode = .recenter
        
    }
    
    //MARK: Table view datasource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        var service: NTMapPermissionResult?
        
        if (indexPath as NSIndexPath).section == 0 && basemaps.count > 0 {
            service = basemaps[indexPath.row]
        } else if (indexPath as NSIndexPath).section >= 0 && layers.count > 0 {
            service = layers[indexPath.row]
        }
        
        cell.textLabel?.text = service?.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "header")!
        
        if section == 0 && basemaps.count > 0 {
            cell.textLabel?.text = "Basemap"
        }
        else {
            cell.textLabel?.text = "Layer"
        }
        cell.textLabel?.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 && basemaps.count > 0 {
            return basemaps.count
        }
        else if section >= 0 && layers.count > 0 {
            return layers.count
        }
        else {
            return 0
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if basemaps.count > 0 && layers.count > 0 {
            return 2
        }
        else if basemaps.count > 0 || layers.count > 0 {
            return 1
        }
        else {
            return 0
        }
    }
}
