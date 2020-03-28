//
//  RoomsViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomsViewController: ASViewController<ASTableNode> {
    weak var coordinator: RoomsCoordinator? {
        didSet {
            guard let _ = self.coordinator else { print("HomeCoordinator is not loaded"); return }
        }
    }
    
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
        
        subscribeOnEvents()
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = HomeSearchController()
        navigationItem.searchController?.delegate = self
        navigationItem.searchController?.searchBar.delegate = self
        // we can tap inside view with that
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
    }
    
    private func subscribeOnEvents() {
        guard let userId = ShareData().userdata?.id else { return }
        
        FayeEventRoomBinder(with: userId)
            .subscribe(
                onNew: { (roomSchema) in
                    self.insertRoom(with: roomSchema)
            },
                onRemove: { (roomId) in
                    self.deleteRoom(by: roomId)
            },
                onPatch: { (roomSchema) in
                    
            }
        )
    }
    
    @objc func reload(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text != "" {
            self.viewModel.suggestedRoomsSearchQuery(with: text) { (rooms) in
                DispatchQueue.main.async {
                    self.coordinator?.showSuggestedRoom(with: rooms)
                }
            }
            
        } else {
            showSuggestedRooms()
        }
    }
    
    private func deleteRoom(by passedId: String) {
        if let index = self.viewModel.dataSource?.data.value.firstIndex(where: { (room) in
            room.id == passedId
        }) {
            self.viewModel.dataSource?.data.value.remove(at: index)
            
            self.tableNode.performBatch(animated: true, updates: {
                tableNode.deleteRows(at: [IndexPath(row: index - 1, section: 0)], with: .fade)
            }, completion: nil)
        }
    }
    
    private func insertRoom(with room: RoomSchema) {
        self.viewModel.dataSource?.data.value.append(room)
        self.tableNode.performBatch(animated: true, updates: {
            if let counted = self.viewModel.dataSource?.data.value.count {
                tableNode.insertRows(at: [IndexPath(row: counted - 1, section: 0)], with: .fade)
            } else {
                tableNode.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }
        }, completion: nil)
    }
}

extension RoomsViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        showSuggestedRooms()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        view = tableNode.view
    }
    
    private func showSuggestedRooms() {
        coordinator?.showSuggestedRoom(with: self.viewModel.suggestedRoomsData)
    }
}

extension RoomsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload(_:)), object: searchBar)
        self.perform(#selector(reload(_:)), with: searchBar, afterDelay: 0.5)
    }
}
