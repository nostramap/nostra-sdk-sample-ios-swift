//
//  FuelAdminiPolyViewController.swift
//  FuelSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK

class FuelAdminPolyViewController: UIViewController, FuelListAdminPolyDelegate {

    var province: NTAdministrative?
    var amphoe: NTAdministrative?
    
    @IBOutlet weak var btnProvince: UIButton!
    @IBOutlet weak var btnAmphoe: UIButton!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "provinceSegue" {
            let adminPolyListViewController = segue.destination as? FuelListAdminPolyViewController
            adminPolyListViewController?.delegate = self
            
        } else if segue.identifier == "amphoeSegue" {
            let adminPolyListViewController = segue.destination as? FuelListAdminPolyViewController
            adminPolyListViewController?.delegate = self
            adminPolyListViewController?.adminLevel1Code = province?.code
        } else if segue.identifier == "resultSegue" {
            let resultViewController = segue.destination as? FuelResultVendorViewController
            resultViewController?.adminLevel1Code = province?.code
            resultViewController?.adminLevel2Code = amphoe?.code
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var ret = true
        
        if identifier == "amphoeSegue" {
            ret = province != nil
        } else if identifier == "resultSegue" {
            ret = province != nil && amphoe != nil
        }
        
        
        return ret
    }
    
    func didFinishSelectProvice(_ provice: NTAdministrative) {
        self.province = provice
        btnProvince.setTitle(province?.localName, for: .normal)
    }
    
    func didFinishSelectAmphoe(_ amphoe: NTAdministrative) {
        self.amphoe = amphoe
        btnAmphoe.setTitle(amphoe.localName, for: .normal)
    }
    
}
