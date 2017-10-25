//
//  FuelResultViewController.swift
//  FuelSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK

class FuelResultVendorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var adminLevel1Code: String?;
    var adminLevel2Code: String?;
    
    var latitude: Double?
    var longitude: Double?
    
    var results: [NTFuelResult]?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        var param: NTFuelParameter! = nil;
        
        if let code1 = self.adminLevel1Code, let code2 = self.adminLevel2Code {
            param = NTFuelParameter(adminLevel1Code: code1, adminLevel2Code: code2);
        }
        else {
            param = NTFuelParameter(latitude: latitude, longitude: longitude);
        }
        
        do {
            let resultSet = try NTFuelService.execute(param);
            results = resultSet.results;
        }
        catch let error {
            print("error: \(error.localizedDescription)");
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "priceSegue" {
            let priceViewController = segue.destination as? FuelResultPriceViewController;
            let result = sender as! NTFuelResult;
            priceViewController?.title = result.localBrandName;
            priceViewController?.result = result
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = results![indexPath.row];
        
        self.performSegue(withIdentifier: "priceSegue", sender: result);
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell"), let result = results?[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = result.localBrandName

        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results != nil ? (results?.count)! : 0;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
}
