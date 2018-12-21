//
//  ViewController.swift
//  DynamicContentSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import ArcGIS
import NOSTRASDK

class MainDMCViewController: UIViewController, AGSMapViewLayerDelegate, AGSLayerDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnHideMenu: UIButton!
    
    @IBOutlet weak var tableLeading: NSLayoutConstraint!
    
    var results: [NTDynamicContentListResult]?
    
    
    let referrer = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.initializeMap();

        do {
            let resultSet = try NTDynamicContentListService.execute();
            self.results = resultSet.results;
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
            let dmcListViewController = segue.destination as! DMCListViewController;
            
            dmcListViewController.dmcResult = sender as! NTDynamicContentListResult;
            
        }
    }
    
    @IBAction func layerMenuButtonClicked(_ sender: Any) {
        if tableLeading.constant == 0 {
            self.btnHideLayer_Clicked(sender);
            
            btnHideMenu.isHidden = true;
        }
        else {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.75)
            tableLeading.constant = 0;
            UIView.commitAnimations();
            btnHideMenu.isHidden = false;
        }
    }
    
    @IBAction func btnHideLayer_Clicked(_ sender: Any) {
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.75)
        tableLeading.constant = -180;
        UIView.commitAnimations();
        
        btnHideMenu.isHidden = true

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = self.results?[indexPath.row];
        self.performSegue(withIdentifier: "maintoDMCListSegue", sender: result);
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell");
        
        let result = self.results?[indexPath.row];
        cell?.textLabel?.text = result?.localName
        
        return cell!;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results != nil ? self.results!.count : 0;
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    
    
    
    
    //MARK: Layer delegate
    func mapViewDidLoad(_ mapView: AGSMapView!) {
        mapView.locationDisplay.startDataSource()
        
        let env = AGSEnvelope(xmin: 10458701.000000, ymin: 542977.875000,
                              xmax: 11986879.000000, ymax: 2498290.000000,
                              spatialReference: AGSSpatialReference.webMercator());
        mapView.zoom(to: env, animated: true);
        
        
    }
    
    func initializeMap() {
        
        mapView.layerDelegate = self;
        
        do {
            
            // Get map permisson.
            let resultSet = try NTMapPermissionService.execute();
            
            // Get Street map HD (service id: 2)
            if let results = resultSet.results, results.count > 0 {
                let filtered = results.filter({ (mp) -> Bool in
                    return mp.serviceId == 2
                })
                
                if let mapPermisson = filtered.first, let url = mapPermisson.localService?.url {
                    let cred = AGSCredential(token: mapPermisson.localService?.token, referer: referrer);
                    if let tiledLayer = AGSTiledMapServiceLayer(url: url, credential: cred) {
                        tiledLayer.delegate = self
                        mapView.addMapLayer(tiledLayer, withName: mapPermisson.name)
                    }
                }
            }
        }
        catch let error as NSError {
            print("error: \(error)");
        }
    }
}

