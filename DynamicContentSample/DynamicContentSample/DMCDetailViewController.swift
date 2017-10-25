//
//  DMCDetailViewController.swift
//  DynamicContentSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK
class DMCDetailViewController: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblAdd_Info: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var lblTelNo: UILabel!
    @IBOutlet weak var lblWebsite: UILabel!
    
    var result: NTDynamicContentResult?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let result = self.result {
            lblName.text = result.localName;
            lblAddress.text = result.localAddress;
            lblAdd_Info.text = result.additionalInfo?.localInfo;
            lblDetail.text = result.detail?.localInfo;
            lblTelNo.text = result.telephoneNumber;
            lblWebsite.text = result.website?.absoluteString;
        }
        
    }

   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnShare_Clicked(_ sender: AnyObject) {
        
        do {
            if let result = self.result, let point = result.point {
                let location = NTLocation(name: result.localName, latitude: point.latitude, longitude: point.longitude);
                let param = NTShortLinkParameter(location: location);
                let shareResult = try NTShortLinkService.execute(param);
                
                let alertController = UIAlertController(title: "Share", message: shareResult.url?.absoluteString, preferredStyle: .alert);
                let actionCopy = UIAlertAction(title: "Copy", style: .default, handler: { (action) in
                    UIPasteboard.general.string = shareResult.url?.absoluteString;
                })
                let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
                
                alertController.addAction(actionCopy);
                alertController.addAction(actionCancel);
                
                self.present(alertController, animated: true, completion: nil);
            }
            
        }
        catch {}
        
        
    }



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "detailtoMapSegue" {
            let mapViewController = segue.destination as! DMCMapViewController;
            mapViewController.result = result;
        }
    }


}
