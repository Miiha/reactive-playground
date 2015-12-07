//
//  SearchViewController.swift
//  Reactive Playground
//
//  Created by Michael Kao on 20/11/15.
//  Copyright © 2015 Michael Kao. All rights reserved.
//

import UIKit
import RxSwift

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    @IBOutlet weak var tableView: UITableView!

    let cellIdentifier = "WordCell"

    let searchResultController: UISearchController!
    let apiClient = ApiClient()
    let dataSource = Variable<Array<String>>([])

    var disposeBag = DisposeBag()

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
        
        searchResultController.searchBar.rx_text
            .throttle(0.5, MainScheduler.sharedInstance)
            .flatMapLatest { query -> Observable<[String]> in
                return self.apiClient.searchObservable(query)
                    .observeOn(MainScheduler.sharedInstance)
                    .doOn(onError: { error in
                        self.tableView.animateColor(UIColor.redColor())
                    })
                    .catchErrorJustReturn([])
            }
            .subscribeNext({ result in
                self.dataSource.value = result
                self.tableView.reloadData()
            })
            .addDisposableTo(disposeBag)
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
