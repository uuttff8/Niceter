//
//  CreateRoomViewController.swift
//  Niceter
//
//  Created by uuttff8 on 4/12/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class CreateRoomViewController: ASViewController<ASTableNode> {
    weak var coordinator: CreateRoomCoordinator?
    
    lazy var viewModel: CreateRoomViewModel = CreateRoomViewModel(dataSource: self.tableDelegates)
    
    private lazy var tableDelegates = CreateRoomTableDelegates(with: self.coordinator!)
    private var tableNode: ASTableNode {
        return node
    }
    
    init(coordinator: CreateRoomCoordinator) {
        self.coordinator = coordinator
        super.init(node: ASTableNode(style: .grouped))
        self.tableNode.dataSource = self.tableDelegates
        self.tableNode.delegate = self.tableDelegates
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Room".localized()
        self.hideKeyboardWhenTappedAround()
        setupNavigationControllerButtons()
        
        self.tableDelegates.data.addAndNotify(observer: self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.tableNode.reloadData()
            }
        }
        
        self.viewModel.adminGroupsData.addAndNotify(observer: self) { [weak self] in
            guard let self = self else { return }
            self.tableDelegates.adminGroups = self.viewModel.adminGroupsData.value
        }
        
        self.viewModel.fetchDataSource()
        self.viewModel.fetchAdminGroups()
    }
    
    private func setupNavigationControllerButtons() {
        let doneButton = UIBarButtonItem(title: "Create".localized(),
                                         style: .done,
                                         target: self,
                                         action: #selector(doneButtonAction(_:)))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc private func doneButtonAction(_ sender: UIBarButtonItem) {
        guard let community = self.tableDelegates.selectedCommunity else {
            self.showOkAlert(config: .init(title: "Please, specify community".localized(),
                                           subtitle: nil))
            return
        }
        
        guard let text = self.tableDelegates.roomName else {
            self.showOkAlert(config: .init(title: "Room name is not valid".localized(),
                                           subtitle: nil))
            return
        }
        
        guard text.rangeOfCharacter(from: CharacterSet.gitterValidRoomName.inverted) == nil else {
            self.showOkAlert(config: .init(title: "Names must be alphanumeric with no spaces. Dashes are allowed".localized(),
                                           subtitle: nil))
            return
        }
        
        sender.isEnabled = false
        
        self.viewModel.createRoom(roomName: text,
                                  topic: self.tableDelegates.topicDescription,
                                  community: community,
                                  securityPrivate: self.tableDelegates.isPrivateSwitchActive,
                                  privateMembers:  self.tableDelegates.isPrivateMemberSwitchActive)
        { (res) in
            switch res {
            case .success(_):
                // on success, room automatically appears in rooms
                self.dismiss(animated: true, completion: nil)
            case .failure(let error):
                self.handleBackendError(error)
                
                sender.isEnabled = true
            }
        }
    }
    
    private func handleBackendError(_ error: (GitterApiErrors.CreateRoomError)) {
        switch error {
            
        case .conflict:
            self.showOkAlert(config: .init(title: "There is already a room with that name.", subtitle: nil))
        case .unknown:
            self.showOkAlert(config: .init(title: "Unknown Error happen. Try again Later", subtitle: nil))
        }
    }

}

private extension CharacterSet {
    static var gitterValidRoomName: NSMutableCharacterSet {
        let validRoomNameCharacters = NSMutableCharacterSet()
        validRoomNameCharacters.formUnion(with: CharacterSet.alphanumerics)
        validRoomNameCharacters.addCharacters(in: "-")
        return validRoomNameCharacters
    }
}
