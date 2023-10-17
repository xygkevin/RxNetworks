//
//  AnimatedLoadingPlugin.swift
//  RxNetworks
//
//  Created by Condy on 2023/4/12.
//

import Foundation
import Moya

/// 动画加载插件，基于Lottie封装
/// Animation loading plugin, based on Lottie package.
public struct AnimatedLoadingPlugin: PluginPropertiesable {
    
    public var plugins: APIPlugins = []
    
    public var key: String?
    
    public var delay: Double {
        options.delayHideHUD
    }
    
    public let options: Options
    
    public init(options: Options = .init()) {
        self.options = options
    }
    
    /// Hide the loading hud.
    public func hideLoadingHUD() {
        let vc = X.removeHUD(key: key)
        vc?.close()
    }
}

extension AnimatedLoadingPlugin {
    public struct Options {
        /// Loading will not be automatically hidden and display window.
        public static let dontAutoHide: Options = .init(autoHide: false)
        
        /// Do you need to display an error message, the default is empty
        let displayLoadText: String
        /// Delay hidden, the default is zero seconds
        let delayHideHUD: Double
        /// Do you need to automatically hide the loading hud.
        let autoHideLoading: Bool
        /// Set up this loading animated JSON file named.
        let animatedJSON: String?
        
        public init(text: String = "正在加载...", delay: Double = 0.0, autoHide: Bool = true, animatedJSON: String? = nil) {
            self.displayLoadText = text
            self.delayHideHUD = delay
            self.animatedJSON = animatedJSON
            self.autoHideLoading = autoHide
        }
    }
}

extension AnimatedLoadingPlugin: PluginSubType {
    
    public var pluginName: String {
        return "AnimatedLoading"
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        DispatchQueue.main.async {
            showHUD()
        }
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if options.autoHideLoading == false, case .success = result {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + options.delayHideHUD) {
            self.hideLoadingHUD()
        }
    }
}

extension AnimatedLoadingPlugin {
    
    private func showHUD() {
        guard let key = self.key else {
            return
        }
        if let vc = X.readHUD(key: key) {
            vc.show()
        } else {
            let animatedNamed = self.options.animatedJSON ?? NetworkConfig.animatedJSON
            let hud = LoadingHud(frame: .zero, animatedNamed: animatedNamed)
            hud.textLabel.text = self.options.displayLoadText
            let vc = LevelStatusBarWindowController()
            vc.key = key
            vc.showUpView = hud
            vc.show()
            X.saveHUD(key: key, window: vc)
        }
    }
}
