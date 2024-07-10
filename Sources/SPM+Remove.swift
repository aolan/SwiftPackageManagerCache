//
//  SPM+Remove.swift
//
//
//  Created by lawn on 2024/6/12.
//

import Foundation
import ArgumentParser
import FileKit

extension SPM {
    
    static func remove(path: String) throws {
        guard let remoteURLString = SPM.toRemoteURLString(path) else {
            throw SPMError.invaildLocalRepo("本地镜像仓库链接不合法，示例：/Users/xxx/Library/Caches/com.spm.tool/repos_mirror/github.com/SnapKit/SnapKit.git")
        }
        // 判断镜像仓库是否已经存在，已存在，先删除掉
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue {
            Log.info("查找到要删除的镜像仓库")
            do {
                Log.info("删除中...")
                try FileManager.default.removeItem(atPath: path)
                Log.success("删除成功")
            } catch {
                Log.error("删除失败")
                throw SPMError.deleteLocalRepoFailed("删除已有镜像仓库失败")
            }
        }
        // 移除 git config 配置，相当于还原配置
        Log.info("移除 git config 配置...")
        let command = "git config --global --unset-all url.'\(path)'.insteadOf \(remoteURLString)"
        Shell.execute(command)
        Log.success("移除完成")
    }
    
    
    // MARK: 子命令
    struct Remove: ParsableCommand {
        static var configuration: CommandConfiguration = CommandConfiguration(commandName: "remove", abstract: "移除指定的已缓存镜像仓库")
        @Argument(help: "本地镜像仓库路径，示例：/Users/xxx/Library/Caches/com.spm.tool/repos_mirror/github.com/SnapKit/SnapKit.git")
        var path: String
        
        mutating func run() throws {
            try SPM.remove(path: path)
        }
    }
}
