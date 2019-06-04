//
//  FuelListAdminPolyViewController.swift
//  FuelSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK

protocol FuelListAdminPolyDelegate {
    func didFinishSelectProvice(_ provice: NTAdministrative)
    func didFinishSelectAmphoe(_ amphoe: NTAdministrative)
}

class FuelListAdminPolyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var adminLevel1Code: String?
    
    var results: [NTAdministrative]?
    var delegate: FuelListAdminPolyDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let param = NTAdministrativeParameter()
        
        if let code = self.adminLevel1Code {
            param.adminLevel1Code = code
            
        }
        do {
            let resultSet = try NTAdministrativeService.execute(param)
            results = resultSet.results
        }
        catch let error as NSError {
            print("error: \(error.description)")
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if let result = results?[indexPath.row] {
            cell?.textLabel?.text = result.localName
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let result = results?[indexPath.row] {
            if self.adminLevel1Code == nil {
                delegate?.didFinishSelectProvice(result)
            }
            else
            {
                delegate?.didFinishSelectAmphoe(result)
            }
            _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results != nil ? (results?.count)! : 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
