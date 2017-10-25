//
//  RouteDetailViewController.swift
//  RouteSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK
import ArcGIS
class RouteDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var directions: [NTDirection]! = nil;

    override func viewDidLoad() {
        super.viewDidLoad();
        tableView.estimatedRowHeight = 44.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell");
        let direction = directions[indexPath.row];
        
        
        let lblDirection = cell?.viewWithTag(101) as! UILabel;
        let lblLength = cell?.viewWithTag(102) as! UILabel;
        
        lblDirection.text = direction.text;
        lblLength.text = String.init(format: "%.1f Km.", direction.length / 1000);
        
        
        return cell!;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directions != nil ? directions.count : 0;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

}
