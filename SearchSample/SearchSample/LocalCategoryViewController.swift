//
//  LocalCategoryViewController.swift
//  SearchSample
//
//  Copyright © 2559 Globtech. All rights reserved.
//

import UIKit
import NOSTRASDK

class LocalCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var localCateogries: [NTLocalCategory]?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NTLocalCategoryService.executeAsync(nil, Completion: { (resultSet, error) in
            DispatchQueue.main.async(execute: { 
                if let err = error {
                    print("error \(err.localizedDescription)")
                }
                else {
                    self.localCateogries = resultSet?.results
                }
                self.tableView.reloadData();
            })
            
        });
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "localCategorytoResultSegue" {
            let resultViewController = segue.destination as! ResultViewController;
            
            resultViewController.searchByLocalCategory(sender as? String);
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let category = localCateogries?[indexPath.row] {
            self.performSegue(withIdentifier: "localCategorytoResultSegue", sender: category.categoryCode)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell"), let category = localCateogries?[indexPath.row] else {
            return UITableViewCell()
        }
        cell.textLabel?.text = category.englishName
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localCateogries != nil ? localCateogries!.count : 0;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

}
