//
//  MarkOnMapViewController.swift
//  SearchAlongTheRouteSample
//
//  Copyright © 2560 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var points: [NTPoint]?
    var results: [NTSearchAlongRouteResult]?
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let keyword = searchBar.text, !keyword.isEmpty {
            
            let param = NTSearchAlongRouteParameter(points: points,
                                                    searchType: .searchForClosestPlaces,
                                                    keyword: keyword)
            
            NTSearchAlongRouteService.executeAsync(param, Completion: { (resultSet, error) in
                DispatchQueue.main.async {
                    if let err = error {
                        print(err.localizedDescription)
                    }
                    else {
                        if let searchResults = resultSet?.results {
                            self.results = searchResults
                            self.tableView.reloadData()
                        }
                    }
                }
            })
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        if let result = results?[indexPath.row] {
            cell.textLabel?.text = result.localName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results != nil ? results!.count : 0
    }
    
    
}

