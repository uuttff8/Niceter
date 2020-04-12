//
//  RoomsViewController.swift
//  Gittker
//
//  Created by uuttff8 on 3/3/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class RoomsViewController: ASViewController<ASTableNode> {
    
    // MARK: - Variables
    weak var coordinator: RoomsCoordinator?
    
    private let refreshControl = UIRefreshControl()
    private lazy var dataSource = RoomsDataSource()
    private lazy var tableDelegate = RoomsTableViewDelegate(with: self)
    
    private var tableNode: ASTableNode {
        return node
    }
    
    lazy var viewModel: RoomsViewModel = {
        return RoomsViewModel(dataSource: self.dataSource)
    }()
    
    init(coordinator: RoomsCoordinator) {
        self.coordinator = coordinator
        super.init(node: ASTableNode())
        
        refreshControl.addTarget(self, action: #selector(reloadRooms(_:)), for: .valueChanged)
        self.tableNode.delegate = self.tableDelegate
        self.tableNode.dataSource = self.dataSource
        self.tableNode.view.refreshControl = self.refreshControl
        
        tableNode.view.separatorStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rooms"
        self.setupSearchBar()
        self.setupNavigationBar()
        
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
    
    // MARK: - Setuping UI
    private func setupSearchBar() {
        navigationItem.searchController = UISearchController()
        navigationItem.searchController?.delegate = self
        navigationItem.searchController?.searchBar.delegate = self
        // we can tap inside view with that
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
    }
    
    private func setupNavigationBar() {
        let createRoomButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(RoomsViewController.createRoomAction(_:)))
        navigationItem.rightBarButtonItem = createRoomButton
    }
    
    // MARK: - Events
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
                    self.diffRoomById(with: roomSchema)
            }
        )
    }
    
    // Objc Action
    @objc func reloadRooms(_ sender: Any) {
        self.viewModel.fetchRooms()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    @objc func createRoomAction(_ sender: Any) {
        coordinator?.showCreateRoom()
    }
    
    @objc func reload(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text != "" {
            self.viewModel.suggestedRoomsSearchQuery(with: text) { (rooms) in
                DispatchQueue.main.async { [weak self] in
                    self?.coordinator?.showSuggestedRoom(with: rooms, currentlyJoinedRooms: (self?.viewModel.dataSource?.data.value)!)
                }
            }
        } else {
            showSuggestedRooms()
        }
    }
}

// MARK: - Inserting and Deleting
extension RoomsViewController {
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
        if !checkIfOneToOne(room: room) { return }
        
        self.viewModel.dataSource?.data.value.append(room)
        self.tableNode.performBatch(animated: true, updates: { [weak self] in
            if let counted = self?.viewModel.dataSource?.data.value.count {
                self?.tableNode.insertRows(at: [IndexPath(row: counted - 1, section: 0)], with: .fade)
            } else {
                self?.tableNode.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }
        }, completion: nil)
    }
    
    private func diffRoomById(with room: RoomSchema) {
        if let index = viewModel.dataSource?.data.value.firstIndex(where: { (roomSchema) -> Bool in
            room.id == roomSchema.id
        }) {
            
            if let newLastAccessTime = room.lastAccessTime {
                self.viewModel.dataSource?.data.value[index].lastAccessTime = newLastAccessTime
                self.tableNode.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
                        
            if let newUnreadedItems = room.unreadItems {
                self.viewModel.dataSource?.data.value[index].unreadItems = newUnreadedItems
                self.tableNode.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
            
            if let newTopic = room.topic {
                self.viewModel.dataSource?.data.value[index].topic = newTopic
                self.tableNode.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
    
    private func checkIfOneToOne(room: RoomSchema) -> Bool {
        room.oneToOne == false
    }
}

// MARK: - Search UI Logic
extension RoomsViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        showSuggestedRooms()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        view = tableNode.view
    }
    
    private func showSuggestedRooms() {
        coordinator?.showSuggestedRoom(with: self.viewModel.suggestedRoomsData, currentlyJoinedRooms: (self.viewModel.dataSource?.data.value)!)
    }
}

// MARK: - Seatch Logic
extension RoomsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload(_:)), object: searchBar)
        self.perform(#selector(reload(_:)), with: searchBar, afterDelay: 0.5)
    }
}
