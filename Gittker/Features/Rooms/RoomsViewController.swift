//
//  RoomsViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomsViewController: ASViewController<ASTableNode> {
    var typedText: ((_ text: String) -> Void)?
    
    weak var coordinator: RoomsCoordinator? {
        didSet {
            guard let _ = self.coordinator else { print("HomeCoordinator is not loaded"); return }
        }
    }
    
    var suggestedRoomController: SuggestedRoomsNode?
    
    private let dataSource = RoomsDataSource()
    private var tableDelegate = RoomsTableViewDelegate()
    
    private var tableNode: ASTableNode {
        return node
    }
    
    lazy var viewModel: RoomsViewModel = {
        return RoomsViewModel(dataSource: self.dataSource)
    }()
    
    init() {
        super.init(node: ASTableNode())
        suggestedRoomController = SuggestedRoomsCoordinator(with: navigationController, room: viewModel.suggestedRoomsData).currentController
        
        self.tableNode.delegate = self.tableDelegate
        self.tableNode.dataSource = self.dataSource
        
        tableNode.view.separatorStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rooms"
        self.setupSearchBar()
        
        self.dataSource.data.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableDelegate.coordinator = self.coordinator
                self.tableDelegate.dataSource = self.dataSource.data.value
                self.tableNode.reloadData()
            }
        }
        
        self.viewModel.fetchRoomsCached()
        self.viewModel.fetchSuggestedRooms()
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = HomeSearchController()
        navigationItem.searchController?.delegate = self
        navigationItem.searchController?.searchBar.delegate = self
        // we can tap inside view with that
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
    }
    
    @objc func reload(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text != "" {
            self.viewModel.suggestedRoomsSearchQuery(with: text) { (rooms) in
                DispatchQueue.main.async {
                    self.view = SuggestedRoomsCoordinator(with: self.navigationController,
                                                          room: rooms)
                        .currentController?
                        .view
                }
            }
            
        } else {
            view = SuggestedRoomsCoordinator(with: navigationController, room: viewModel.suggestedRoomsData).currentController?.view
            
        }
    }
}

extension RoomsViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        view = SuggestedRoomsCoordinator(with: navigationController, room: viewModel.suggestedRoomsData).currentController?.view
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        view = tableNode.view
    }
}

extension RoomsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload(_:)), object: searchBar)
        self.perform(#selector(reload(_:)), with: searchBar, afterDelay: 0.5)
    }
}
