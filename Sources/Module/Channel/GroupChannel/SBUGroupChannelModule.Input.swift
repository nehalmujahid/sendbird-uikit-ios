//
//  SBUGroupChannelModule.Input.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/01/16.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import PhotosUI
import SendbirdChatSDK


/// Event methods for the views updates and performing actions from the input component in the group channel.
public protocol SBUGroupChannelModuleInputDelegate: SBUBaseChannelModuleInputDelegate {
    
    /// Called when a file was picked to send a file message.
    /// - Parameters:
    ///   - inputComponent: `SBUGroupChannelModule.Input` object.
    ///   - fileData: A data of a picked file.
    ///   - mimeType: A MIME type of a picked file.
    ///   - parentMessage: A message that will be a parent message. Please refer to *quote reply* features.
    func groupChannelModule(
        _ inputComponent: SBUGroupChannelModule.Input,
        didPickFileData fileData: Data?,
        fileName: String,
        mimeType: String,
        parentMessage: BaseMessage?
    )
    
    /// Called when the send button was tapped.
    /// - Parameters:
    ///    - inputComponent: `SBUGroupChannelModule.Input` object.
    ///    - text: The normal text.
    ///    - mentionedMessageTemplate: The mentioned text that is generated by `text` and `mentionUsers`.
    ///    - mentionedUserIds: The mentioned userIds.
    ///    - parentMessage: The parent message of the message representing `text`.
    /// ```swift
    /// print(text) // "Hi @Nickname"
    /// print(mentionedMessageTemplate) // "Hi @{UserID}"
    /// print(mentionedUserIds) // ["{UserID}"]
    /// ```
    func groupChannelModule(
        _ inputComponent: SBUGroupChannelModule.Input,
        didTapSend text: String,
        mentionedMessageTemplate: String,
        mentionedUserIds: [String],
        parentMessage: BaseMessage?
    )
    
    /// Called when the edit button was tapped.
    /// - Parameters:
    ///    - inputComponent: `SBUGroupChannelModule.Input` object.
    ///    - text: The normal text
    ///    - mentionedMessageTemplate: The mentioned text that is generated by `text` and `mentionUsers`.
    ///    - mentionedUserIds: The mentioned userIds.
    /// ```swift
    /// print(text) // "Hi @Nickname"
    /// print(mentionedMessageTemplate) // "Hi @{UserID}"
    /// print(mentionedUserIds) // ["{UserID}"]
    /// ```
    func groupChannelModule(
        _ inputComponent: SBUGroupChannelModule.Input,
        didTapEdit text: String,
        mentionedMessageTemplate: String,
        mentionedUserIds: [String]
    )
    
    /// Called when the `SBUMessageInputMode` will be changed.
    /// - Parameters:
    ///    - inputComponent: `SBUGroupChannelModule.Input` object.
    ///    - mode: `SBUMessageInputMode` value.
    ///    - mentionedMessageTemplate: The mentioned text that is generated by `mentionUsers`.
    ///    - mentionedUserIds: The mentioned userIds.
    func groupChannelModule(
        _ inputComponent: SBUGroupChannelModule.Input,
        willChangeMode mode: SBUMessageInputMode,
        message: BaseMessage?,
        mentionedMessageTemplate: String,
        mentionedUserIds: [String]
    )
    
    /// Called when the suggested mentions should be loaded. Please refer to `loadSuggestedMentions(with:)` function in `SBUGroupChannelViewModel`.
    /// - Parameters:
    ///   - inputComponent: `SBUGroupChannelModule.Input` object.
    ///   - filterText: The text that is used as a filter while loading the suggested mentions.
    func groupChannelModule(
        _ inputComponent: SBUGroupChannelModule.Input,
        shouldLoadSuggestedMentions filterText: String
    )
    
    /// Called when it the suggested mentions are no longer valid.
    /// - Parameter inputComponent: `SBUGroupChannelModule.Input` object.
    func groupChannelModuleShouldStopSuggestingMention(
        _ inputComponent: SBUGroupChannelModule.Input
    )
}

/// Methods to get data source for the input component in the group channel.
public protocol SBUGroupChannelModuleInputDataSource: SBUBaseChannelModuleInputDataSource { }

extension SBUGroupChannelModule {
    /// The `SBUGroupChannelModule`'s component class that represents input
    @objc(SBUGroupChannelModuleInput)
    @objcMembers open class Input: SBUBaseChannelModule.Input, SBUMentionManagerDelegate, SBUSuggestedMentionListDelegate {
        public var suggestedMentionList: SBUSuggestedMentionList?
        
        /// A current quoted message in message input view. This value is only available when the `messageInputView` is type of `SBUMessageInputView` that supports the message replying feature.
        public var currentQuotedMessage: BaseMessage? {
            guard let messageInputView = messageInputView as? SBUMessageInputView else { return nil }
            var parentMessage: BaseMessage? = nil
            switch messageInputView.option {
                case .quoteReply(let message):
                    parentMessage = message
                default: break
            }
            messageInputView.setMode(.none)
            return parentMessage
        }
        
        /// The group channel object casted from `baseChannel`.
        public var channel: GroupChannel? {
            self.baseChannel as? GroupChannel
        }
        
        /// The object that acts as the delegate of the input component. The delegate must adopt the `SBUGroupChannelModuleInputDelegate`.
        public weak var delegate: SBUGroupChannelModuleInputDelegate? {
            get { self.baseDelegate as? SBUGroupChannelModuleInputDelegate }
            set { self.baseDelegate = newValue }
        }
        
        /// The object that acts as the data source of the input component. The data source must adopt the `SBUGroupChannelModuleInputDataSource`.
        public weak var dataSource: SBUGroupChannelModuleInputDataSource? {
            get { self.baseDataSource as? SBUGroupChannelModuleInputDataSource }
            set { self.baseDataSource = newValue }
        }
        
        /// The object that acts as the data source of the mention manager. The data source must adopt the `SBUMentionManagerDataSource`.
        public weak var mentionManagerDataSource: SBUMentionManagerDataSource?
        
        // MARK: Mention
        public var mentionManager: SBUMentionManager?
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUGroupChannelModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUGroupChannelModuleInputDataSource`
        ///   - theme: `SBUChannelTheme` object
        open func configure(
            delegate: SBUGroupChannelModuleInputDelegate,
            dataSource: SBUGroupChannelModuleInputDataSource,
            mentionManagerDataSource: SBUMentionManagerDataSource? = nil,
            theme: SBUChannelTheme
        ) {
            self.delegate = delegate
            self.dataSource = dataSource
            self.mentionManagerDataSource = mentionManagerDataSource
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
            
            if SBUGlobals.isUserMentionEnabled {
                self.setupMentionManager()
            }
        }
        
        open override func setupViews() {
            super.setupViews()
        }
        
        open override func setupLayouts() {
            super.setupLayouts()
            
            self.messageInputView?
                .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        }
        
        open override func pickImageFile(info: [UIImagePickerController.InfoKey : Any]) {
            var tempImageURL: URL? = nil
            if let imageURL = info[.imageURL] as? URL {
                // file:///~~~
                tempImageURL = imageURL
            }
            
            guard let imageURL = tempImageURL else {
                let originalImage = info[.originalImage] as? UIImage
                // for Camera capture
                guard let image = originalImage?
                        .fixedOrientation()
                        .resize(with: SBUGlobals.imageResizingSize) else { return }
                
                let imageData = image.jpegData(
                    compressionQuality: SBUGlobals.isImageCompressionEnabled ?
                    SBUGlobals.imageCompressionRate : 1.0
                )
                
                let parentMessage = self.currentQuotedMessage
                
                self.delegate?.groupChannelModule(
                    self,
                    didPickFileData: imageData,
                    fileName: "\(Date().sbu_toString(dateFormat: SBUDateFormatSet.Message.fileNameFormat, localizedFormat: false)).jpg",
                    mimeType: "image/jpeg",
                    parentMessage: parentMessage
                )
                return
            }
            
            let imageName = imageURL.lastPathComponent
            guard let mimeType = SBUUtils.getMimeType(url: imageURL) else {
                SBULog.error("Failed to get mimeType from `SBUUtils.getMimeType(url:)`")
                return
            }
            
            switch mimeType {
                case "image/gif":
                    let gifData = try? Data(contentsOf: imageURL)
                    
                    let parentMessage = self.currentQuotedMessage
                    
                    self.delegate?.groupChannelModule(
                        self,
                        didPickFileData: gifData,
                        fileName: imageName,
                        mimeType: mimeType,
                        parentMessage: parentMessage
                    )
                default:
                    let originalImage = info[.originalImage] as? UIImage
                    guard let image = originalImage?
                            .fixedOrientation()
                            .resize(with: SBUGlobals.imageResizingSize) else { return }
                    
                    let imageData = image.jpegData(
                        compressionQuality: SBUGlobals.isImageCompressionEnabled ?
                        SBUGlobals.imageCompressionRate : 1.0
                    )
                    
                    let parentMessage = self.currentQuotedMessage
                    self.delegate?.groupChannelModule(
                        self,
                        didPickFileData: imageData,
                        fileName: "\(Date().sbu_toString(dateFormat: SBUDateFormatSet.Message.fileNameFormat, localizedFormat: false)).jpg",
                        mimeType: "image/jpeg",
                        parentMessage: parentMessage
                    )
            }
        }
        
        open override func pickVideoFile(info: [UIImagePickerController.InfoKey : Any]) {
            do {
                guard let videoURL = info[.mediaURL] as? URL else { return }
                let videoFileData = try Data(contentsOf: videoURL)
                let videoName = videoURL.lastPathComponent
                guard let mimeType = SBUUtils.getMimeType(url: videoURL) else { return }
                
                let parentMessage = self.currentQuotedMessage
                
                self.delegate?.groupChannelModule(
                    self,
                    didPickFileData: videoFileData,
                    fileName: videoName,
                    mimeType: mimeType,
                    parentMessage: parentMessage
                )
            } catch {
                SBULog.error(error.localizedDescription)
                let sbError = SBError(domain: (error as NSError).domain, code: (error as NSError).code)
                self.delegate?.didReceiveError(sbError, isBlocker: false)
            }
        }
        
        @available(iOS 14.0, *)
        open override func pickImageFile(itemProvider: NSItemProvider) {
            itemProvider.loadItem(forTypeIdentifier: UTType.image.identifier, options: [:]) { url, error in
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] imageItem, error in
                        guard let self = self else { return }
                        guard let originalImage = imageItem as? UIImage else { return }
                        let image = originalImage
                            .fixedOrientation()
                            .resize(with: SBUGlobals.imageResizingSize)
                        let imageData = image.jpegData(
                            compressionQuality: SBUGlobals.isImageCompressionEnabled
                            ? SBUGlobals.imageCompressionRate
                            : 1.0
                        )
                        
                        let parentMessage = self.currentQuotedMessage
                        
                        DispatchQueue.main.async { [self, imageData, parentMessage] in
                            self.delegate?.groupChannelModule(
                                self,
                                didPickFileData: imageData,
                                fileName: "\(Date().sbu_toString(dateFormat: SBUDateFormatSet.Message.fileNameFormat, localizedFormat: false)).jpg",
                                mimeType: "image/jpeg",
                                parentMessage: parentMessage
                            )
                        }
                    }
                }
            }
        }
        
        @available(iOS 14.0, *)
        open override func pickGIFFile(itemProvider: NSItemProvider) {
            itemProvider.loadItem(forTypeIdentifier: UTType.gif.identifier, options: [:]) { [weak self] url, error in
                guard let imageURL = url as? URL else { return }
                guard let self = self else { return }
                let imageName = imageURL.lastPathComponent
                let gifData = try? Data(contentsOf: imageURL)
                
                let parentMessage = self.currentQuotedMessage
                
                DispatchQueue.main.async { [self, gifData, parentMessage] in
                    self.delegate?.groupChannelModule(
                        self,
                        didPickFileData: gifData,
                        fileName: imageName,
                        mimeType: "image/gif",
                        parentMessage: parentMessage
                    )
                }
            }
        }
        
        @available(iOS 14.0, *)
        open override func pickVideoFile(itemProvider: NSItemProvider) {
            itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                guard let videoURL = url else { return }
                guard let self = self else { return }
                do {
                    let videoFileData = try Data(contentsOf: videoURL)
                    let videoName = videoURL.lastPathComponent
                    guard let mimeType = SBUUtils.getMimeType(url: videoURL) else { return }
                    
                    let parentMessage = self.currentQuotedMessage
                    
                    DispatchQueue.main.async { [self, videoFileData, videoName, mimeType, parentMessage] in
                        self.delegate?.groupChannelModule(
                            self,
                            didPickFileData: videoFileData,
                            fileName: videoName,
                            mimeType: mimeType,
                            parentMessage: parentMessage
                        )
                    }
                } catch {
                    SBULog.error(error.localizedDescription)
                }
            }
        }
        
        open override func pickDocumentFile(documentURLs: [URL]) {
            do {
                guard let documentURL = documentURLs.first else { return }
                let documentData = try Data(contentsOf: documentURL)
                let documentName = documentURL.lastPathComponent
                guard let mimeType = SBUUtils.getMimeType(url: documentURL) else { return }
                
                let parentMessage = self.currentQuotedMessage
                
                self.delegate?.groupChannelModule(
                    self,
                    didPickFileData: documentData,
                    fileName: documentName,
                    mimeType: mimeType,
                    parentMessage: parentMessage
                )
            } catch {
                SBULog.error(error.localizedDescription)
                let sbError = SBError(domain: (error as NSError).domain, code: (error as NSError).code)
                self.delegate?.didReceiveError(sbError, isBlocker: false)
            }
        }
        
        open override func pickImageData(_ data: Data) {
            let parentMessage = self.currentQuotedMessage
            
            self.delegate?.groupChannelModule(
                self,
                didPickFileData: data,
                fileName: "\(Date().sbu_toString(dateFormat: SBUDateFormatSet.Message.fileNameFormat, localizedFormat: false)).jpg",
                mimeType: "image/jpeg",
                parentMessage: parentMessage
            )
        }
        
        open override func pickVideoURL(_ url: URL) {
            do {
                let videoFileData = try Data(contentsOf: url)
                let videoName = url.lastPathComponent
                guard let mimeType = SBUUtils.getMimeType(url: url) else { return }
                
                let parentMessage = self.currentQuotedMessage
                
                self.delegate?.groupChannelModule(
                    self,
                    didPickFileData: videoFileData,
                    fileName: videoName,
                    mimeType: mimeType,
                    parentMessage: parentMessage
                )
            } catch {
                SBULog.error(error.localizedDescription)
                let sbError = SBError(domain: (error as NSError).domain, code: (error as NSError).code)
                self.delegate?.didReceiveError(sbError, isBlocker: false)
            }
        }
        
        open override func updateMessageInputMode(_ mode: SBUMessageInputMode, message: BaseMessage? = nil) {
            super.updateMessageInputMode(mode, message: message)
            if mode == .edit {
                guard SBUGlobals.isUserMentionEnabled else { return }
                guard let messageInputView = self.messageInputView as? SBUMessageInputView else { return }
                guard let mentionedUsers = message?.mentionedUsers else { return }
                guard let mentionedMessageTemplate = message?.mentionedMessageTemplate,
                      mentionedMessageTemplate != "" else { return }
                
                if let mentionManager = mentionManager {
                    mentionManager.reset()
                } else {
                    self.mentionManager = SBUMentionManager()
                    self.mentionManager?.configure(
                        delegate:self,
                        dataSource: self.mentionManagerDataSource,
                        defaultTextAttributes: messageInputView.defaultAttributes,
                        mentionTextAttributes: messageInputView.mentionedAttributes
                    )
                }
                
                
                let attributedText = self.mentionManager!.generateMentionedMessage(
                    with: mentionedMessageTemplate,
                    mentionedUsers: SBUUser.convertUsers(mentionedUsers)
                )
                messageInputView.textView?.attributedText = attributedText
            }
        }
        
        /// Updates state of `messageInputView`.
        open override func updateMessageInputModeState() {
            if channel != nil {
                self.updateBroadcastModeState()
                self.updateFrozenModeState()
                self.updateMutedModeState()
            } else {
                if let messageInputView = self.messageInputView as? SBUMessageInputView {
                    messageInputView.setErrorState()
                }
            }
        }
        
        /// This is used to update frozen mode of `messageInputView`. This will call `SBUBaseChannelModuleInputDelegate baseChannelModule(_:didUpdateFrozenState:)`
        open override func updateFrozenModeState() {
            let isOperator = self.channel?.myRole == .operator
            let isBroadcast = self.channel?.isBroadcast ?? false
            let isFrozen = self.channel?.isFrozen ?? false
            if !isBroadcast {
                if let messageInputView = self.messageInputView as? SBUMessageInputView {
                    messageInputView.setFrozenModeState(!isOperator && isFrozen)
                }
            }
            self.delegate?.baseChannelModule(self, didUpdateFrozenState: isFrozen)
        }
        
        /// Updates the mode of `messageInputView` according to broadcast state of the channel.
        open func updateBroadcastModeState() {
            let isOperator = self.channel?.myRole == .operator
            let isBroadcast = self.channel?.isBroadcast ?? false
            self.messageInputView?.isHidden = !isOperator && isBroadcast
        }
        
        /// Updates the mode of `messageInputView` according to frozen and muted state of the channel.
        open func updateMutedModeState() {
            let isOperator = self.channel?.myRole == .operator
            let isFrozen = self.channel?.isFrozen ?? false
            let isMuted = self.channel?.myMutedState == .muted
            if !isFrozen || (isFrozen && isOperator) {
                if let messageInputView = self.messageInputView as? SBUMessageInputView {
                    messageInputView.setMutedModeState(isMuted)
                }
            }
        }
        
        
        // MARK: Mention
        
        /// Initializes `SBUMentionManager` instance and configure with attributes.
        /// The `messageInputView` updates to use its `defaultAttributes` and `mentionedAttributes`.
        open func setupMentionManager() {
            guard SBUGlobals.isUserMentionEnabled else { return }
            
            if mentionManager == nil {
                self.mentionManager = SBUMentionManager()
            }
            
            guard let messageInputView = self.messageInputView as? SBUMessageInputView,
                  let mentionManager = self.mentionManager else { return }
            
            mentionManager.configure(
                delegate: self,
                dataSource: self.mentionManagerDataSource,
                defaultTextAttributes: messageInputView.defaultAttributes,
                mentionTextAttributes: messageInputView.mentionedAttributes
            )
            
            messageInputView.textView?.typingAttributes = mentionManager.defaultTextAttributes
            messageInputView.textView?.linkTextAttributes = mentionManager.mentionTextAttributes
        }
        
        /// Handles pending mention suggestion. This calls when the channel view model receives member list from callback.
        open func handlePendingMentionSuggestion(with members: [SBUUser]?) {
            self.mentionManager?.handlePendingMentionSuggestion()
        }
        
        /// Updates `suggestedMentionList` with `members`
        open func updateSuggestedMentionList(with members: [SBUUser]) {
            var filteredMembers = members.filter {
                $0.userId != SBUGlobals.currentUser?.userId
            }
            
            if let limit = SBUGlobals.userMentionConfig?.suggestionLimit,
               filteredMembers.count > limit {
                // Remove buffer member
                filteredMembers.removeLast()
            }
            
            if self.suggestedMentionList?.superview == nil, filteredMembers.count > 0 {
                self.presentSuggestedMentionList()
            }
            guard let suggestedMentionList = suggestedMentionList else { return }

            let mentionLimit = SBUGlobals.userMentionConfig?.mentionLimit ?? 10
            if let mentionedList = mentionManager?.mentionedList, mentionedList.count < mentionLimit {
                suggestedMentionList.isLimitGuideEnabled = false
            } else {
                suggestedMentionList.isLimitGuideEnabled = true
            }
            suggestedMentionList.reloadData(with: filteredMembers)
            
            let height = CGFloat(44 * filteredMembers.count)
            let maxHeight: CGFloat
            switch UIDevice.current.orientation {
            case .landscapeRight, .landscapeLeft:
                maxHeight = 164
            default:
                maxHeight = 196
            }
            suggestedMentionList.heightConstraint.constant = suggestedMentionList.isLimitGuideEnabled
            ? 44
            : min(height, maxHeight)
            
            self.layoutIfNeeded()
        }
        
        /// Presents `suggestedMentionList`
        open func presentSuggestedMentionList() {
            if suggestedMentionList == nil {
                self.suggestedMentionList = SBUSuggestedMentionList()
                self.suggestedMentionList?.delegate = self
            }
            
            guard let suggestedMentionList = suggestedMentionList else { return }
            guard let messageInputView = self.messageInputView else { return }
            
            self.addSubview(suggestedMentionList)
            
            suggestedMentionList.translatesAutoresizingMaskIntoConstraints = false
            suggestedMentionList.heightConstraint = suggestedMentionList.heightAnchor.constraint(equalToConstant: 0)
            
            suggestedMentionList
                .sbu_constraint(equalTo: self, leading: 0, trailing: 0)
                .sbu_constraint_equalTo(
                    bottomAnchor:
                        (messageInputView as? SBUMessageInputView)?.contentHStackView.topAnchor
                        ?? messageInputView.topAnchor,
                    bottom: 0
                )
                .sbu_constraint_lessThan(height: 196)
            
            NSLayoutConstraint.activate([
                suggestedMentionList.heightConstraint
            ])
        }
        
        /// Dismiss `suggestedMentionList` and remove from super view.
        open func dismissSuggestedMentionList() {
            guard let suggestedMentionList = self.suggestedMentionList else { return }
            
            suggestedMentionList.reloadData(with: [])
            
            suggestedMentionList.removeFromSuperview()
            self.suggestedMentionList = nil
            self.setupLayouts()
        }
        
        open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            guard let suggestedMentionList = suggestedMentionList, suggestedMentionList.superview != nil else {
                return super.point(inside: point, with: event)
            }
            let tounchedInside = bounds
                .insetBy(dx: 0, dy: -suggestedMentionList.bounds.height)
                .contains(point)
            if !tounchedInside {
                self.dismissSuggestedMentionList()
            }
            return tounchedInside
        }
        
        open override func messageInputView(_ messageInputView: SBUMessageInputView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            guard let textView = messageInputView.textView else { return false }
            return self.mentionManager?.shouldChangeText(
                on: textView,
                in: range,
                replacementText: text
            ) ?? true
        }
        
        open override func messageInputView(_ messageInputView: SBUMessageInputView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            // TODO: Mention tap action
            return true
        }
        
        open override func messageInputView(_ messageInputView: SBUMessageInputView, didChangeSelection range: NSRange) {
            guard let textView = messageInputView.textView else { return }
            guard let mentionManager = self.mentionManager else { return }

            guard !mentionManager.needToSkipSelection(textView) else { return }
            
            self.mentionManager?.handleMentionSuggestion(on: textView, range: range)
        }
        
        /// Called when the send button was selected.
        /// - Parameters:
        ///    - messageInputView: `SBUMessageinputView` object.
        ///    - text: The sent text.
        /// - NOTE: If there's mentions in `mentionManager.mentionedList`, It invokes ``messageInputView(_:didSelectSend:mentionManager:)`` instead.
        open override func messageInputView(_ messageInputView: SBUMessageInputView, didSelectSend text: String) {
            if let textView = messageInputView.textView,
                let mentionManager = mentionManager,
                mentionManager.mentionedList.isEmpty == false {
                self.messageInputView(messageInputView, didSelectSend: textView.attributedText, mentionManager: mentionManager)
            } else {
                super.messageInputView(messageInputView, didSelectSend: text)
            }
        }
        
        /// Called when the message input mode will be changed via `setMode(_:message:)` method.
        /// - Parameters:
        ///    - messageInputView: `SBUMessageinputView` object.
        ///    - mode: `SBUMessageInputMode` value. The `messageInputView` changes its mode to this value.
        ///    - message: `BaseMessage` object. It's `nil` when the `mode` is `none`.
        /// - NOTE: If there's mentions in `mentionManager.mentionedList`, It invokes ``messageInputView(_:willChangeMode:message:mentionManager:)`` instead.
        open override func messageInputView(_ messageInputView: SBUMessageInputView, willChangeMode mode: SBUMessageInputMode, message: BaseMessage?) {
            if let mentionManager = mentionManager,
                mentionManager.mentionedList.isEmpty == false {
                self.messageInputView(messageInputView, willChangeMode: mode, message: message, mentionManager: mentionManager)
            } else {
                super.messageInputView(messageInputView, willChangeMode: mode, message: message)
            }
        }
        
        /// Called when the message input mode will be changed via `setMode(_:message:)` method and need to reset the `mentionManager`.
        open func messageInputView(_ messageInputView: SBUMessageInputView, willChangeMode mode: SBUMessageInputMode, message: BaseMessage?, mentionManager: SBUMentionManager) {
            let mentionedMessageTemplate: String
            if let text = messageInputView.textView?.attributedText {
                mentionedMessageTemplate = mentionManager.generateTemplate(
                    with: text,
                    mentions: mentionManager.mentionedList
                )
            } else {
                mentionedMessageTemplate = ""
            }
            
            self.delegate?.groupChannelModule(
                self,
                willChangeMode: mode,
                message: message,
                mentionedMessageTemplate: mentionedMessageTemplate,
                mentionedUserIds: mentionManager.mentionedList.compactMap { $0.user.userId }
            )
            mentionManager.reset()
        }
        
        open func messageInputView(_ messageInputView: SBUMessageInputView, didSelectSend text: NSAttributedString, mentionManager: SBUMentionManager) {
            var parentMessage: BaseMessage?
            
            switch messageInputView.option {
                case .quoteReply(let message):
                    parentMessage = message
                default:
                    break
            }
            self.delegate?.groupChannelModule(
                self,
                didTapSend: text.string,
                mentionedMessageTemplate: mentionManager.generateTemplate(
                    with: text,
                    mentions: mentionManager.mentionedList
                ),
                mentionedUserIds: mentionManager.mentionedList.compactMap { $0.user.userId },
                parentMessage: parentMessage
            )
            messageInputView.setMode(.none)
            
            mentionManager.reset()
        }
        
        open override func messageInputView(_ messageInputView: SBUMessageInputView, didSelectEdit text: String) {
            if let textView = messageInputView.textView,
                let mentionManager = mentionManager,
                mentionManager.mentionedList.isEmpty == false {
                self.messageInputView(messageInputView, didSelectEdit: textView.attributedText, mentionManager: mentionManager)
            } else {
                super.messageInputView(messageInputView, didSelectEdit: text)
            }
        }
        
        open func messageInputView(_ messageInputView: SBUMessageInputView, didSelectEdit text: NSAttributedString, mentionManager: SBUMentionManager) {
            
            self.delegate?.groupChannelModule(
                self,
                didTapEdit: text.string,
                mentionedMessageTemplate: mentionManager.generateTemplate(
                    with: text,
                    mentions: mentionManager.mentionedList
                ),
                mentionedUserIds: mentionManager.mentionedList.compactMap { $0.user.userId }
            )
            mentionManager.reset()
        }
        
        // MARK: SBUMentionManagerDelegate
        open func mentionManager(_ manager: SBUMentionManager,
                                 didChangeSuggestedMention members: [SBUUser],
                                 filteredText: String?,
                                 isTriggered: Bool) {
            guard isTriggered else {
                self.dismissSuggestedMentionList()
                self.delegate?.groupChannelModuleShouldStopSuggestingMention(self)
                return
            }
            
            if self.suggestedMentionList?.superview == nil {
                self.presentSuggestedMentionList()
            }
            self.updateSuggestedMentionList(with: members)
        }
        
        open func mentionManager(_ manager: SBUMentionManager, didInsertMentionsTo textView: UITextView) {
            self.dismissSuggestedMentionList()
        }
        
        open func mentionManager(_ manager: SBUMentionManager, shouldLoadSuggestedMentions keyword: String) {
            self.delegate?.groupChannelModule(self, shouldLoadSuggestedMentions: keyword)
        }
        
        // MARK: SBUSuggestedMentionListDelegate
        open func suggestedUserList(_ list: SBUSuggestedMentionList, didSelectUser user: SBUUser) {
            guard let textView = (self.messageInputView as? SBUMessageInputView)?.textView else { return }
            self.mentionManager?.addMention(at: textView, user: user)
        }
    }
}
