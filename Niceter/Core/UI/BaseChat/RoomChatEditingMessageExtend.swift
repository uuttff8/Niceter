//
//  RoomChatEditingMessageExtend.swift
//  Niceter
//
//  Created by uuttff8 on 4/24/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import MessageKit
import InputBarAccessoryView
import SnapKit

protocol EditingMessagePluginDelegate: AnyObject {
    func editingMessage(_ manager: EditingMessageInputPlugin, shouldBecomeVisible: Bool)
}

final class EditingMessageView: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: 44)
    }
}

open class EditingMessageInputPlugin: NSObject, InputPlugin {
    weak var delegate: EditingMessagePluginDelegate?
    
    open lazy var editingMessageView: UIView = { [weak self] in
        let view = EditingMessageView()
        view.backgroundColor = UIColor.systemBackground
        return view
        }()
    
    let previousMessageLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.label
        return lbl
    }()
    
    let cancelButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        return btn
    }()
    
    func showEditingMessage(message: String) {
        delegate?.editingMessage(self, shouldBecomeVisible: true)
        
        editingMessageView.addSubview(cancelButton)
        editingMessageView.addSubview(previousMessageLabel)
        
        previousMessageLabel.text = message
        
        cancelButton.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(44)
        }
        previousMessageLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(18)
            make.width.equalTo(100)
        }
        
        cancelButton.addTap {
            self.delegate?.editingMessage(self, shouldBecomeVisible: false)
        }
    }
    
    public func reloadData() {
        print("First")
    }
    
    public func invalidate() {
        print("Invalidate")
    }
    
    public func handleInput(of object: AnyObject) -> Bool {
        return true
    }
}

class RoomChatEditingMessageExtend: RoomChatBaseViewController, EditingMessagePluginDelegate {
    
    // should be implemented
    func updateMessageRequest(message: MockMessage) { }
    
    lazy var editingMessagePlugin: EditingMessageInputPlugin = { [unowned self] in
        let plug = EditingMessageInputPlugin()
        plug.delegate = self
        return plug
    }()
    
    private var message: MockMessage?
    private var previousText: String?
    private var previousTextInTextView: String?
    
    private var isEditingEnabled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageInputBar.inputPlugins.append(editingMessagePlugin)
    }
    
    override func editMessageUI(message: MockMessage) {
        self.message = message
        self.previousTextInTextView = messageInputBar.inputTextView.text
        
        guard case .text(let messageText) = self.message?.kind else { return }
        self.previousText = messageText
        editingMessagePlugin.showEditingMessage(message: messageText)
    }
    
    func editingMessage(_ manager: EditingMessageInputPlugin, shouldBecomeVisible: Bool) {
        let topStackView = messageInputBar.topStackView
        guard case .text(let messageText) = self.message?.kind else { return }
        
        if shouldBecomeVisible && !topStackView.arrangedSubviews.contains(editingMessagePlugin.editingMessageView) {
            self.isEditingEnabled = true
            messageInputBar.inputTextView.text = messageText
            messageInputBar.sendButton.isEnabled = false
            messageInputBar.inputTextView.delegate = self
            
            topStackView.insertArrangedSubview(editingMessagePlugin.editingMessageView,
                                               at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
            
        } else if !shouldBecomeVisible && topStackView.arrangedSubviews.contains(editingMessagePlugin.editingMessageView) {
            self.isEditingEnabled = false
            messageInputBar.inputTextView.text = previousTextInTextView
            messageInputBar.inputTextView.delegate = nil
            
            topStackView.removeArrangedSubview(editingMessagePlugin.editingMessageView)
            editingMessagePlugin.editingMessageView.removeFromSuperview()
            topStackView.layoutIfNeeded()
        }
        
        messageInputBar.invalidateIntrinsicContentSize()
    }
        
    override func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if isEditingEnabled {
            // if editing enabled then message is not nil
            guard var message = message else { return }
            message.kind = MessageKind.text(messageInputBar.inputTextView.text)
            editMessage(message: message)
        } else {
            super.inputBar(inputBar, didPressSendButtonWith: text)
        }
    }
}

extension RoomChatEditingMessageExtend: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        if self.previousText != textView.text &&
            messageInputBar.sendButton.isEnabled &&
            self.messageInputBar.sendButton.isUserInteractionEnabled {
            return
        } else if self.previousText != textView.text {
            self.messageInputBar.sendButton.isEnabled = true
            self.messageInputBar.sendButton.isUserInteractionEnabled = true
        } else if self.previousText == textView.text {
            self.messageInputBar.sendButton.isEnabled = false
            self.messageInputBar.sendButton.isUserInteractionEnabled = false
        }
    }
}
