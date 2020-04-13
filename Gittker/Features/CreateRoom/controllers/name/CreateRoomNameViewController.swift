//
//  CreateRoomNameViewController.swift
//  Gittker
//
//  Created by uuttff8 on 4/13/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import AsyncDisplayKit

class CreateRoomNameViewController: ASViewController<ASTableNode> {
    let viewModel: CreateRoomNameViewModel = CreateRoomNameViewModel()
    
    weak var coordinator: CreateRoomCoordinator?
    
    private var tableNode: ASTableNode {
        return node
    }
    
    private var repoSelected: ((String) -> Void)?
    private var ghRepoEnabled: Bool
    
    var completionHandler: ((String) -> Void)?
    
    init(coordinator: CreateRoomCoordinator, ghRepoEnabled: Bool) {
        self.coordinator = coordinator
        self.ghRepoEnabled = ghRepoEnabled
        super.init(node: ASTableNode(style: .grouped))
        self.tableNode.dataSource = self
        self.tableNode.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ghRepoEnabled == false {
            viewModel.getRepos()
            
            viewModel.repos.addAndNotify(observer: self) {
                self.tableNode.reloadData()
            }
        }
    }
}

extension CreateRoomNameViewController: ASTableDelegate, ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return CreateRoomNameSection.allCases.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let section = CreateRoomNameSection.allCases[indexPath.section]
        return {
            var returnCell = ASCellNode()
            
            switch section {
            case .enterName:
                let content = TextFieldNodeCell.Content(defaultText: nil)
                let cell = TextFieldNodeCell(with: content, delegate: self)
                returnCell = cell
                
                self.repoSelected = { (text) in
                    cell.textFieldNode.attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.label,
                                                                                                      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
                    cell.textFieldNode.delegate?.editableTextNodeDidUpdateText?(cell.textFieldNode)
                    returnCell = cell
                }
            case .suggested:
                let repo = self.viewModel.repos.value[indexPath.row]
                let cell = CreateRoomRepoNodeCell(with: repo)
                cell.drawPrivateRepoEmoji()
                returnCell = cell
            }
            
            return returnCell
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let section = CreateRoomNameSection.allCases[indexPath.section]
        
        switch section {
        case .suggested:
            let repo = self.viewModel.repos.value[indexPath.row]
            repoSelected?(repo.name)
            tableNode.deselectRow(at: indexPath, animated: true)
        default: break
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case CreateRoomNameSection.enterName.rawValue:
            return 1
        case CreateRoomNameSection.suggested.rawValue:
            return viewModel.repos.value.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = CreateRoomNameSection.allCases[section]
        return section.footerTitle
    }
    
}

extension CreateRoomNameViewController: ASEditableTextNodeDelegate {
    func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reloadText(_:)), object: editableTextNode)
        self.perform(#selector(reloadText(_:)), with: editableTextNode, afterDelay: 0.5)
    }
    
    @objc func reloadText(_ editableTextNode: ASEditableTextNode) {
        completionHandler?(editableTextNode.attributedText?.string ?? "")
    }
}

private enum CreateRoomNameSection: Int, CaseIterable {
    case enterName
    case suggested
    
    var footerTitle: String {
        switch self {
        case .enterName:
            return "Optionally link with GitHub Repo"
        default: return ""
        }
    }
}
