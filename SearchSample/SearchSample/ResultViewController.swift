//
//  ResultViewController.swift
//  SearchSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK
import CoreLocation

class ResultViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var results: [NTLocationSearchResult]?

    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    func searchByKeyword(_ keyword: String?) {
        if let key = keyword {
            let param = NTLocationSearchParameter(keyword: key)
            self.searchWithParam(param);
        }
        else {
            self.performUnabletoSearch();
        }
    }
    
    func searchByCategory(_ category: String?) {
        if let cate = category {
            let param = NTLocationSearchParameter(categoryCodes: [cate])
            self.searchWithParam(param);
        }
        else {
            self.performUnabletoSearch();
        }

    }
    
    func searchByLocalCategory(_ localCategory: String?) {
        if let localCat = localCategory {
            let param = NTLocationSearchParameter(localCategoryCodes: [localCat])
            self.searchWithParam(param);
        }
        else {
            self.performUnabletoSearch();
        }
    }
    
    
    func searchWithParam(_ param: NTLocationSearchParameter) {
        NTLocationSearchService.executeAsync(param, Completion: { (resultSet, error) in
            DispatchQueue.main.async(execute: {
                if let err = error {
                    self.results = []
                    print("error: \(err.localizedDescription)")
                    
                }
                else {
                    self.results = resultSet?.results
                }
                self.tableView.reloadData()
            })
            
        });
    }
    
    
    func performUnabletoSearch() {
        let alertController = UIAlertController(title: "Unable to search", message: "Please check your location.", preferredStyle: .alert);
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            _ = self.navigationController?.popViewController(animated: true);
        }));
        
        self.present(alertController, animated: true, completion: nil);
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapResultSegue" {
            let mapResultViewController = segue.destination as? MapResultViewController;
            mapResultViewController?.result = sender as? NTLocationSearchResult;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let result = results![indexPath.row];
        self.performSegue(withIdentifier: "mapResultSegue", sender: result);
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell"), let result = results?[indexPath.row] else {
            return UITableViewCell()
        }
        
        if let name = result.localName {
            cell.textLabel?.text = name
        }
        
        if let admin1 = result.adminLevel1?.localName, let admin2 = result.adminLevel2?.localName, let admin3 = result.adminLevel3?.localName {
            cell.detailTextLabel?.text = "\(admin3), \(admin2), \(admin1)"
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results != nil ? (results?.count)! : 0;
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    
}
