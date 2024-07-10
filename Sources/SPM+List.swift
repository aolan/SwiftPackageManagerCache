//
//  SPM+List.swift
//
//
//  Created by lawn on 2024/6/12.
//

import Foundation
import ArgumentParser
import FileKit

extension SPM {
    
    struct List: ParsableCommand {
        
        static var configuration: CommandConfiguration = CommandConfiguration(commandName: "list", abstract: "查看已缓存的镜像仓库列表")
        
        mutating func run() throws {
            
            let repoDirs = Path(SPM.cacheDir).find(searchDepth: 3) { path in path.pathExtension == "git" }
            if repoDirs.count == 0 {
                Log.success("暂未缓存任何镜像仓库")
                return
            }
            
            Log.info("已缓存镜像列表，数量：\(repoDirs.count)")
            for repoDir in repoDirs {
                Log.success(repoDir.rawValue)
            }
        }
    }
}
