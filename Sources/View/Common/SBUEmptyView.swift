//
//  SBUEmptyView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 27/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public protocol SBUEmptyViewDelegate: NSObjectProtocol {
    /// Called when the retry button on the empty view was tapped.
    func didSelectRetry()
}


open class SBUEmptyView: SBUView {
    // MARK: - Properties (Public)
    public var type: EmptyViewType = .none
    public weak var delegate: SBUEmptyViewDelegate?
    public lazy var statusImageView = UIImageView()
    public var statusLabel: UILabel = .init()
    
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var theme: SBUComponentTheme
    @SBUThemeWrapper(theme: SBUTheme.overlayTheme.componentTheme, setToDefault: true)
    public var overlayTheme: SBUComponentTheme
    
    public lazy var retryButton: UIButton = {
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        let retryButton = UIButton()
         retryButton.setImage(
             SBUIconSetType.iconRefresh.image(
                 with: theme.emptyViewRetryButtonTintColor,
                 to: SBUIconSetType.Metric.defaultIconSize
             ),
             for: .normal
         )
         retryButton.setTitle(SBUStringSet.Retry, for: .normal)
         retryButton.addTarget(self, action: #selector(onClickRetry), for: .touchUpInside)
         return retryButton
     }()

    // MARK: - Properties (Private)
    var isOverlay = false
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 24
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    
    // MARK: - Lifecycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable, renamed: "SBUEmptyView.init(frame:)")
    required public init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    public override init() {
        super.init()
    }
    
    open override func setupViews() {
        super.setupViews()
        
        self.stackView.alignment = .center
        self.stackView.addArrangedSubview(self.statusImageView)
        self.stackView.addArrangedSubview(self.statusLabel)
        self.stackView.addArrangedSubview(self.retryButton)
        self.retryButton.isHidden = true
        self.addSubview(stackView)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            self.stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            self.stackView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0)
        ])
        
        self.statusImageView.setConstraint(width: 60.0, height: 60.0)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
        self.backgroundColor = theme.emptyViewBackgroundColor
        
        self.statusLabel.font = theme.emptyViewStatusFont
        self.statusLabel.textColor = theme.emptyViewStatusTintColor
        self.statusLabel.contentMode = .center
        self.statusLabel.numberOfLines = 0
        self.statusLabel.lineBreakMode = .byWordWrapping
        //NOTE: this will cause unexpected image when tint with not desirable
        //image
        //self.statusImageView.image = self.statusImageView.image?.sbu_with(tintColor: theme.emptyViewStatusTintColor)
         
        self.retryButton.setTitleColor(theme.emptyViewRetryButtonTintColor, for: .normal)
        self.retryButton.titleLabel?.font = theme.emptyViewRetryButtonFont
        self.retryButton.tintColor = theme.emptyViewRetryButtonTintColor
    }
    
    
    // MARK: - Common
    
    /// This function reloads emptyView.
    /// - Parameter type: Empty view type
    public func reloadData(_ type: EmptyViewType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.type = type
            
            self.retryButton.isHidden = (self.type != .error)
            
            self.updateViews()
            
            self.layoutIfNeeded()
            self.updateConstraintsIfNeeded()
        }
    }
    
    /// Override this function to apply a custom type.
    open func updateViews() {
        self.isHidden = false
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
        switch self.type {
        case .none:
            self.statusLabel.text = ""
            self.statusImageView.image = nil
            self.isHidden = true
        case .noChannels:
            self.statusLabel.text = SBUStringSet.Empty_No_Channels
            self.statusImageView.image = SBUIconSetType.iconChat.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                tintAndResize: false
            )
        case .noMessages:
            self.statusLabel.text = SBUStringSet.Empty_No_Messages
            self.statusImageView.image = SBUIconSetType.iconMessage.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                tintAndResize: false
            )
        case .noMembers:
            self.statusLabel.text = SBUStringSet.Empty_No_Users
            self.statusImageView.image = SBUIconSetType.iconMembers.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                tintAndResize: false
            )
        case .noMutedMembers:
            self.statusLabel.text = SBUStringSet.Empty_No_Muted_Members
            self.statusImageView.image = SBUIconSetType.iconMute.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                tintAndResize: false
            )
        case .noMutedParticipants:
            self.statusLabel.text = SBUStringSet.Empty_No_Muted_Participants
            self.statusImageView.image = SBUIconSetType.iconMute.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                tintAndResize: false
            )
        case .noBannedUsers:
            self.statusLabel.text = SBUStringSet.Empty_No_Banned_Users
            self.statusImageView.image = SBUIconSetType.iconBan.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                tintAndResize: false
            )
        case .noSearchResults:
            self.statusLabel.text = SBUStringSet.Empty_Search_Result
            self.statusImageView.image = SBUIconSetType.iconSearch.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                tintAndResize: false
            )
        case .error:
            self.statusLabel.text = SBUStringSet.Empty_Wrong
            self.statusImageView.image = SBUIconSetType.iconError.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                tintAndResize: false
            )
        }
    }
    
    
    // MARK: - Action
    
    /// This function actions when the retry button click.
    /// - Parameter sender: sender
    @objc open func onClickRetry(_ sender: Any) {
        self.delegate?.didSelectRetry()
    }
}
