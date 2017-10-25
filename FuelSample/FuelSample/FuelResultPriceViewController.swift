//
//  FuelResultPriceViewController.swift
//  FuelSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK

class FuelResultPriceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let fuelType = ["Diesel","Diesel Premium","Gasohol91","Gasohol95","GasoholE20","GasoholE85","Gasoline91","Gasoline95","NGV"];
    var result: NTFuelResult?;
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell");
        
        let lblType = cell?.viewWithTag(101) as! UILabel;
        let lblPrice = cell?.viewWithTag(102) as! UILabel;
        
        lblType.text = fuelType[(indexPath as NSIndexPath).row];
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            lblPrice.text = result?.diesel != nil ? String.init(format: "%.2f", (result?.diesel)!) : "-";
        case 1:
            lblPrice.text = result?.dieselPremium != nil ? String.init(format: "%.2f", (result?.dieselPremium)!) : "-";
        case 2:
            lblPrice.text = result?.gasohol91 != nil ? String.init(format: "%.2f", (result?.gasohol91)!) : "-";
        case 3:
            lblPrice.text = result?.gasohol95 != nil ? String.init(format: "%.2f", (result?.gasohol95)!) : "-";
        case 4:
            lblPrice.text = result?.gasoholE20 != nil ? String.init(format: "%.2f", (result?.gasoholE20)!) : "-";
        case 5:
            lblPrice.text = result?.gasoholE85 != nil ? String.init(format: "%.2f", (result?.gasoholE85)!) : "-";
        case 6:
            lblPrice.text = result?.gasoline91 != nil ? String.init(format: "%.2f", (result?.gasoline91)!) : "-";
        case 7:
            lblPrice.text = result?.gasoline95 != nil ? String.init(format: "%.2f", (result?.gasoline95)!) : "-";
        default:
            lblPrice.text = result?.NGV != nil ? String.init(format: "%.2f", (result?.NGV)!) : "-"
        }
        
        return cell!;
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fuelType.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    
    
    
}
