//
//  KeywordViewcontroller.swift
//  SearchSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK

class KeywordViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var keywords: [String]?
    
    var param: NTAutocompleteParameter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "keywordtoResultSegue" {
            let resultViewController = segue.destination as! ResultViewController
            
            resultViewController.searchByKeyword(sender as? String)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count > 0 {
            param = NTAutocompleteParameter(keyword: searchText)
            
            NTAutocompleteService.executeAsync(param!) { (resultSet, error) in
                
                DispatchQueue.main.async(execute: {
                    if let err = error {
                        self.keywords = []
                        print("error: \(err.localizedDescription)")
                    }
                    else {
                        self.keywords = resultSet?.results
                    }
                    self.tableView.reloadData()
                })
                
            }
        }
        
        
        
        
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let keyword = keywords?[indexPath.row] {
            self.performSegue(withIdentifier: "keywordtoResultSegue", sender: keyword)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell"), let keyword = keywords?[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = keyword
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords != nil ? keywords!.count : 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
}
