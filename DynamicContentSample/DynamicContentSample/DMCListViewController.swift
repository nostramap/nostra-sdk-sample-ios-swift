//
//  DMCListViewController.swift
//  DynamicContentSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK

class DMCListViewController: UITableViewController {

    var dmcResult: NTDynamicContentListResult?
    var results:[NTDynamicContentResult]?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
            if let layerId = self.dmcResult?.layerId {
                let param = NTDynamicContentParameter(layerId: layerId, latitude: 13.746832,
                                                      longitude: 100.534886)
                
                let resultSet = try NTDynamicContentService.execute(param)
                
                results = resultSet.results
            }
            
            
        }
        catch {}

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell"), let results = self.results else {
            return UITableViewCell()
        }
        
        let result = results[indexPath.row]
        
        cell.textLabel?.text = result.localName
        cell.detailTextLabel?.text = result.localAddress
        
        if let url = result.iconUrl, let data = try? Data.init(contentsOf: url) {
            cell.imageView?.image = UIImage(data: data)
        }
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let result = results?[indexPath.row] {
            self.performSegue(withIdentifier: "resulttoDetailSegue", sender: result)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results != nil ? results!.count : 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "resulttoDetailSegue" {
            let detailViewController = segue.destination as? DMCDetailViewController
            detailViewController?.result = sender as? NTDynamicContentResult
        }
    }

}
