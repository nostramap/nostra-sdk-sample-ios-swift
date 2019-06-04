//
//  ViewController.swift
//  DynamicContentSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import ArcGIS
import NOSTRASDK

class MainDMCViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnHideMenu: UIButton!
    
    @IBOutlet weak var tableLeading: NSLayoutConstraint!
    
    var results: [NTDynamicContentListResult]?
    
    
    let referrer = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initializeMap()

        do {
            let resultSet = try NTDynamicContentListService.execute()
            self.results = resultSet.results
        }
        catch {
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "maintoDMCListSegue" {
            let dmcListViewController = segue.destination as! DMCListViewController
            
            dmcListViewController.dmcResult = sender as? NTDynamicContentListResult
            
        }
    }
    
    @IBAction func layerMenuButtonClicked(_ sender: Any) {
        if tableLeading.constant == 0 {
            self.btnHideLayer_Clicked(sender)
            
            btnHideMenu.isHidden = true
        }
        else {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.75)
            tableLeading.constant = 0
            UIView.commitAnimations()
            btnHideMenu.isHidden = false
        }
    }
    
    @IBAction func btnHideLayer_Clicked(_ sender: Any) {
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.75)
        tableLeading.constant = -180
        UIView.commitAnimations()
        
        btnHideMenu.isHidden = true

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = self.results?[indexPath.row]
        self.performSegue(withIdentifier: "maintoDMCListSegue", sender: result)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        let result = self.results?[indexPath.row]
        cell?.textLabel?.text = result?.localName
        
        return cell!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results != nil ? self.results!.count : 0
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: Layer delegate
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        mapView.locationDisplay.start(completion: nil)
        
        let env = AGSEnvelope(xMin: 10458701.000000, yMin: 542977.875000,
                              xMax: 11986879.000000, yMax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator())
        mapView.setViewpointGeometry(env, completion: nil)
        
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
            mapView.map?.load(completion: { (error) in
                guard error == nil else { print(error?.localizedDescription ?? ""); return }
                self.mapViewDidLoad(self.mapView)
            })
            
        } catch let error as NSError {
            print("error: \(error)")
        }
    }
}

