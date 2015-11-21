//
//  SearchViewController.swift
//  Rac
//
//  Created by Michael Kao on 20/11/15.
//  Copyright © 2015 Michael Kao. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    @IBOutlet weak var tableView: UITableView!
    
    let searchResultController: UISearchController!
    let api = API()
    let cellIdentifier = "WordCell"
    
    var tableData = Array<String>()

    required init?(coder aDecoder: NSCoder) {
        self.searchResultController = UISearchController(searchResultsController: nil)

        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResultController.searchResultsUpdater = self
        searchResultController.dimsBackgroundDuringPresentation = false
        searchResultController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = searchResultController.searchBar
        
        rac_signalForSelector("updateSearchResultsForSearchController:", fromProtocol: UISearchResultsUpdating.self).toSignalProducer()
            .map({ (tuple: AnyObject?) -> UISearchController? in
                if let tuple = tuple as? RACTuple {
                    return tuple.first as? UISearchController
                }
                return nil
            })
            .map({ searchController -> String? in
                return searchController?.searchBar.text
            })
            .ignoreNil()
            .throttle(1.0, onScheduler: QueueScheduler.mainQueueScheduler)
            .flatMap(.Latest, transform: { query -> SignalProducer<Array<String>, NSError> in
                return self.api.search(query)
                    .flatMapError { error in
                        print("Error Occured: \(error)")
                        return SignalProducer.empty
                }
            })
            .observeOn(UIScheduler())
            .startWithNext { result -> () in
                self.tableData = result
                self.tableView.reloadData()
            }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResultController.active {
            return tableData.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = tableData[indexPath.row]
        
        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
    }
}
