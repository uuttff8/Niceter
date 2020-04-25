//
//  RoomChatAutocompleteExtend.swift
//  Gittker
//
//  Created by uuttff8 on 4/15/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class RoomChatAutocompleteExtend: RoomChatEditingMessageExtend {
    /// The object that manages autocomplete, from InputBarAccessoryView
    lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.messageInputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        return manager
    }()
    
    // Completions loaded async that get appeneded to local cached completions
    var asyncCompletions: [AutocompleteCompletion] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure AutocompleteManager
        autocompleteManager.register(prefix: "@", with: [.font: UIFont.preferredFont(forTextStyle: .body)])
        
        // Set plugins
        messageInputBar.inputPlugins = [autocompleteManager]
    }
}

extension RoomChatAutocompleteExtend: AutocompleteManagerDelegate, AutocompleteManagerDataSource {
    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
        
        struct Internal: Hashable {
            let name: String
            let senderId: String
        }
        
        let messes = messageList.map { (message) in
            Internal(name: message.message.user.username, senderId: message.message.user.senderId)
        }.removingDuplicates()
        
        if prefix == "@" {
            return messes
                .map { message in
                    
                    return AutocompleteCompletion(text: message.name,
                                                  context: ["id": message.senderId])
            }
        }
        return []
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        setAutocompleteManager(active: shouldBecomeVisible)
    }
    
    private func setAutocompleteManager(active: Bool) {
        let topStackView = messageInputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.removeArrangedSubview(autocompleteManager.tableView)
            topStackView.layoutIfNeeded()
        }
        messageInputBar.invalidateIntrinsicContentSize()
    }
}
