//
//  CodableAPI.swift
//  RxNetworks_Example
//
//  Created by Condy on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import RxNetworks

enum CodableAPI: NetworkAPI {
    case cache(Int)
    
    var ip: APIHost {
        return "https://www.httpbin.org"
    }
    
    var path: APIPath {
        return "/post"
    }
    
    var parameters: APIParameters? {
        return ["test": "x12345"]
    }
    
    var plugins: APIPlugins {
        let loading = NetworkLoadingPlugin.init(options: .init(delay: 0.5))
        let ignore = NetworkIgnorePlugin(pluginTypes: [NetworkDebuggingPlugin.self])
        return [loading, ignore]
    }
    
    var stubBehavior: APIStubBehavior {
        return .delayed(seconds: 0.5)
    }
    
    var sampleData: Data {
        switch self {
        case .cache:
            return X.jsonData("Codable")!
        }
    }
}
