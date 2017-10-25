//
//  AddressSearchKeywordViewController.swift
//  AddressSearchSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK
class AddressSearchKeywordViewController: UIViewController {

    @IBOutlet weak var txtKeyword: UITextField!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultSegue" {
            let resultViewController = segue.destination as? AddressSearchResultViewController;
            
            let param = NTAddressSearchParameter(keyword: txtKeyword.text!);
            
            resultViewController?.addressSearchParam = param;
            
        }
    }
    

}
