//
//  SPM+Update.swift
//
//
//  Created by lawn on 2024/6/12.
//

import Foundation
import ArgumentParser
import FileKit

extension SPM {
    
    struct Update: ParsableCommand {
        static var configuration: CommandConfiguration = CommandConfiguration(commandName: "update", abstract: "更新指定的镜像仓库")
        @Argument(help: "远程仓库链接，示例：https://github.com/SnapKit/SnapKit.git")
        var url: String
        
        mutating func run() throws {
            // 判断远程仓库链接是否合法
            if !SPM.validateRemoteUrl(url) {
                throw SPMError.invaildRemoteRepo("远程仓库链接不合法，示例：https://github.com/SnapKit/SnapKit.git")
            }
            // 先删除
            try SPM.remove(path: SPM.toLocalPath(url))
            // 再重新拉取
            try SPM.add(url: url)
        }
    }
}
