//
//  ChainAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks

enum ChainAPI {
    case test
    case test2(String)
}

extension ChainAPI: NetworkAPI {
    
    var ip: APIHost {
        return BoomingSetup.baseURL
    }
    
    var path: APIPath {
        switch self {
        case .test:
            return "/ip"
        case .test2:
            return "/delay/2"
        }
    }
    
    var method: APIMethod {
        switch self {
        case .test: 
            return .get
        case .test2: 
            return .post
        }
    }
    
    var parameters: APIParameters? {
        switch self {
        case .test: 
            return nil
        case .test2(let ip):
            return ["ip": ip]
        }
    }
    
    var plugins: APIPlugins {
        switch self {
        case .test:
            var option = AnimatedLoadingPlugin.Options.init(text: "loading-1..")
            option.autoHideLoading = false
            let loading = AnimatedLoadingPlugin(options: option)
            return [loading]
        case .test2(_):
            let loading = AnimatedLoadingPlugin(options: .init(text: "loading-2.."))
            return [loading]
        }
    }
}
