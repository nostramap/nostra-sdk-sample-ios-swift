//
//  DetailViewController.swift
//  IdentifySample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK

class DetailViewController: UIViewController {
    
    
    var idenResult: NTIdentifyResult?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let param = NTExtraContentParameter(nostraId: idenResult!.nostraId)
            let result = try NTExtraContentService.execute(param)
            
            if let travel = result.travel?.first {
                
                lblName.text = travel.name
                lblInfo.text = travel.attractions?.first?.localAttraction
                lblDetail.text = travel.localHistory
                
                if let url = travel.pictureUrls?.first, let data = try? Data(contentsOf: url) {
                    imageView.image = UIImage(data: data)
                }
                
            }
            else if let food = result.food?.first {
                
                lblName.text = food.name
                lblInfo.text = food.foodTypes?.first?.localDescription
                lblDetail.text = food.entertainmentService?.localService
                
                if let url = food.pictureUrls?.first, let data = try? Data(contentsOf: url) {
                    imageView.image = UIImage(data: data)
                }
            }
            else {
                showAlertDialog(title: "Extra content is not Found", message: nil)
            }
            
        } catch let error {
            showAlertDialog(title: error.localizedDescription, message: nil)
        }
    }
    
    private func showAlertDialog(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
