//
//  WarningAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks

enum WarningAPI {
    case warning
}

extension WarningAPI: NetworkAPI {
    
    var ip: APIHost {
        return NetworkConfig.baseURL
    }
    
    var method: APIMethod {
        return .get
    }
    
    var path: APIPath {
        return "/failed/path"
    }
    
    var plugins: APIPlugins {
        var options = NetworkWarningPlugin.Options.init(duration: 2)
        options.setChangeHudParameters { hud in
            guard let superview = hud.superview else { return }
            hud.center = CGPoint(x: superview.center.x, y: superview.frame.height - 100)
        }
        let warning = NetworkWarningPlugin.init(options: options)
        let loading = NetworkLoadingPlugin.init(options: .init(delay: 0.5))
        return [loading, warning]
    }
}
