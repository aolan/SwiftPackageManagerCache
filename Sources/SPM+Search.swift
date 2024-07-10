//
//  SPM+Search.swift
//  
//
//  Created by lawn.cao on 2024/7/10.
//

import Foundation
import ArgumentParser
import FileKit

extension SPM {
    
    static func search(repoName: String) throws {
        let repoDirs = Path(SPM.cacheDir).find(searchDepth: 3) {
            path in path.pathExtension == "git" && path.rawValue.lowercased().contains(repoName.lowercased())
        }
        if repoDirs.count == 0 {
            Log.success("检索结果：无")
            return
        }
        
        Log.info("检索结果：\(repoDirs.count)")
        for repoDir in repoDirs {
            Log.success(repoDir.rawValue)
        }
    }

    // MARK: 子命令
    struct Search: ParsableCommand {
        static var configuration: CommandConfiguration = CommandConfiguration(commandName: "search", abstract: "缓存仓库的名称，可支持模糊匹配")
        @Argument(help: "缓存仓库的名称，可支持模糊匹配，示例：SnapKit")
        var repoName: String
        
        mutating func run() throws {
            try SPM.search(repoName: repoName)
        }
    }
}
