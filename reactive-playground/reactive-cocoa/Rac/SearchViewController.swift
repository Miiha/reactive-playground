//
//  SearchViewController.swift
//  Reactive Playground
//
//  Created by Michael Kao on 20/11/15.
//  Copyright © 2015 Michael Kao. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    @IBOutlet weak var tableView: UITableView!

    let cellIdentifier = "WordCell"

    let searchResultController: UISearchController!
    let apiClient = ApiClient()
    let dataSource = MutableProperty<Array<String>>([])

    required init?(coder aDecoder: NSCoder) {
        self.searchResultController = UISearchController(searchResultsController: nil)

        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup ui
        searchResultController.searchResultsUpdater = self
        searchResultController.dimsBackgroundDuringPresentation = false
        searchResultController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchResultController.searchBar
        
        // reactive part
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
                return self.apiClient.searchSignal(query)
                    .observeOn(UIScheduler())
                    .on(failed: { error -> () in
                        self.tableView.animateColor(UIColor.redColor())
                    })
                    .flatMapError { error in SignalProducer<Array<String>, NSError>(value: []) }
            })
            .startWithNext({ (result: Array<String>) -> () in
                self.dataSource.value = result
                self.tableView.reloadData()
            })
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResultController.active {
            return dataSource.value.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = dataSource.value[indexPath.row]
        
        return cell
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
    }
}
