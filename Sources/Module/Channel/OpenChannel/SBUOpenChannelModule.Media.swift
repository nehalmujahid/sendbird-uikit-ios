//
//  SBUOpenChannelModule.Media.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/01/17.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK


/// Event methods for the views updates and performing actions from the media component in the open channel.
public protocol SBUOpenChannelModuleMediaDelegate: AnyObject { }

extension SBUOpenChannelModule {
    /// The `SBUOpenChannelModule`'s component class that represents media.
    open class Media: UIView {
        
        /// A view to shows media or other contents in the open channel.
        public var mediaView: UIView = UIView()
        
        /// The object that is used as the theme of the media component. The theme must adopt the `SBUChannelTheme` class.
        public var theme: SBUChannelTheme? = nil
        
        /// The object that acts as the delegate of the media component. The delegate must adopt the `SBUOpenChannelModuleMediaDelegate`.
        public weak var delegate: SBUOpenChannelModuleMediaDelegate?
        
        /// Configures media component.
        /// - Parameters:
        ///   - delegate: `SBUOpenChannelModuleMediaDelegate` type listener
        ///   - theme: `SBUChannelTheme` object
        open func configure(delegate: SBUOpenChannelModuleMediaDelegate, theme: SBUChannelTheme) {
            self.delegate = delegate
            self.theme = theme
            
            setupViews()
            setupLayouts()
            setupStyles()
            
        }
        
        /// Set values of the views in the input component when it needs.
        open func setupViews() {
            self.addSubview(mediaView)
        }
        
        /// Sets layouts of the views in the input component.
        open func setupLayouts() {
            self.mediaView
                .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        }
        
        /// Sets up style with theme. If set theme parameter is `nil`, it uses the stored theme.
        /// - Parameter theme: `SBUChannelTheme` object
        open func setupStyles(theme: SBUChannelTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
        }
    }
}
