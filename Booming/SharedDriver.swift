//
//  SharedDriver.swift
//  RxNetworks
//
//  Created by Condy on 2023/6/28.
//  https://github.com/yangKJ/RxNetworks

import Foundation
import Moya

/// 共享网络中转数据
struct SharedDriver {
    typealias Key = String
    
    static var shared = SharedDriver()
    
    private let lock = NSLock()
    private let tasklock = NSLock()
    
    private var requestingAPIs = [Key: (api: NetworkAPI, plugins: APIPlugins)]()
    private var tasks = [Key: Moya.Cancellable]()
    
    private var cacheBlocks = [(key: Key, success: APISuccess, failure: APIFailure)]()
}

// MARK: - api
extension SharedDriver {
    
    func readRequestAPI(_ key: Key) -> NetworkAPI? {
        self.lock.lock()
        defer { lock.unlock() }
        return self.requestingAPIs[key]?.api
    }
    
    func readRequestPlugins(_ key: Key) -> APIPlugins {
        self.lock.lock()
        defer { lock.unlock() }
        return self.requestingAPIs[key]?.plugins ?? []
    }
    
    mutating func removeRequestingAPI(_ key: Key) {
        self.lock.lock()
        let plugins = self.requestingAPIs[key]?.plugins
        self.requestingAPIs.removeValue(forKey: key)
        // 没有正在请求的网络，则移除全部加载Loading
        if BoomingSetup.lastCompleteAndCloseLoadingHUDs, self.requestingAPIs.isEmpty, let p = plugins {
            let maxTime = X.maxDelayTime(with: p)
            DispatchQueue.main.asyncAfter(deadline: .now() + maxTime) {
                HUDs.removeLoadingHUDs()
            }
        }
        self.lock.unlock()
    }
    
    mutating func addedRequestingAPI(_ api: NetworkAPI, key: Key, plugins: APIPlugins) {
        self.lock.lock()
        self.requestingAPIs[key] = (api, plugins)
        self.lock.unlock()
    }
}

// MARK: - task and blocks
extension SharedDriver {
    
    func readTask(key: Key) -> Moya.Cancellable? {
        self.tasklock.lock()
        defer { tasklock.unlock() }
        return self.tasks[key]
    }
    
    mutating func cacheBlocks(key: Key, success: @escaping APISuccess, failure: @escaping APIFailure) {
        self.tasklock.lock()
        defer { tasklock.unlock() }
        self.cacheBlocks.append((key, success, failure))
    }
    
    mutating func cacheTask(key: Key, task: Moya.Cancellable) {
        self.tasklock.lock()
        defer { tasklock.unlock() }
        self.tasks[key] = task
    }
    
    mutating func result(_ type: Result<APISuccessJSON, APIFailureError>, key: Key) {
        self.tasklock.lock()
        defer { tasklock.unlock() }
        switch type {
        case .success(let json):
            self.cacheBlocks.forEach {
                $0.key == key ? $0.success(json) : nil
            }
        case .failure(let error):
            self.cacheBlocks.forEach {
                $0.key == key ? $0.failure(error) : nil
            }
        }
        self.tasks.removeValue(forKey: key)
        self.cacheBlocks.removeAll { $0.key == key }
    }
}
