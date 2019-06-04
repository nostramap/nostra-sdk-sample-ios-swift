//
//  AddressSearchAttributesViewController.swift
//  AddressSearchSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK

class AddressSearchAttributesViewController: UIViewController {

    @IBOutlet weak var txtHouseNo: UITextField!
    @IBOutlet weak var txtMoo: UITextField!
    @IBOutlet weak var txtSoi: UITextField!
    @IBOutlet weak var txtRoad: UITextField!
    @IBOutlet weak var txtAdminLevel1: UITextField!
    @IBOutlet weak var txtAdminLevel2: UITextField!
    @IBOutlet weak var txtAdminLevel3: UITextField!
    @IBOutlet weak var txtPostcode: UITextField!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultSegue" {
            let resultViewController = segue.destination as? AddressSearchResultViewController
            
            let param = NTAddressSearchParameter()
            
            param.houseNo = txtHouseNo.text
            param.moo = txtMoo.text
            param.soiName = txtSoi.text
            param.adminLevel4Name = txtRoad.text
            param.adminLevel1Name = txtAdminLevel1.text
            param.adminLevel2Name = txtAdminLevel2.text
            param.adminLevel3Name = txtAdminLevel3.text
            param.postcode = txtPostcode.text
            
            resultViewController?.addressSearchParam = param
            
        }
    }

}
