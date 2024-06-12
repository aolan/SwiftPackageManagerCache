//
//  SPM+Add.swift
//
//
//  Created by lawn on 2024/6/12.
//

import Foundation
import ArgumentParser
import FileKit

extension SPM {
    
    struct Add: ParsableCommand {

        static var configuration: CommandConfiguration = CommandConfiguration(commandName: "add", abstract: "缓存指定的镜像仓库")
        
        @Argument(help: "远程仓库链接，示例：https://github.com/SnapKit/SnapKit.git")
        var url: String
        
        mutating func run() throws {
            // 判断远程仓库链接是否合法
            guard let remoteURL = SPM.toRemoteURL(url) else {
                throw SPMError.invaildRemoteRepo("远程仓库链接不合法，示例：https://github.com/SnapKit/SnapKit.git")
            }
            
            // 将 https://github.com 替换成本地路径
            let repoDir = "\(SPM.cacheDir)\(remoteURL.deletingLastPathComponent().relativePath)"
            let repoPath = "\(SPM.cacheDir)\(remoteURL.relativePath)"
            let repoURL = URL(fileURLWithPath: repoDir, isDirectory: true)

            // 判断缓存路径不存在，创建路径
            var isDir: ObjCBool = false
            if !FileManager.default.fileExists(atPath: repoDir, isDirectory: &isDir) || !isDir.boolValue {
                do {
                    Log.info("创建镜像仓库组织路径...")
                    try FileManager.default.createDirectory(at: repoURL, withIntermediateDirectories: true)
                    Log.success("创建成功")
                } catch {
                    Log.error("创建失败")
                    throw SPMError.createDirFailed("镜像仓库组织路径创建失败")
                }
            }
            
            // 判断镜像仓库是否已经存在，已存在，就结束了，不操作了
            if FileManager.default.fileExists(atPath: repoPath, isDirectory: &isDir) && isDir.boolValue {
                Log.success("镜像仓库已存在，无需添加")
                return
            }
            
            // 先移除 git config 配置，否则拉不到远程仓库
            Log.info("移除 git config 配置...")
            var command = "git config --local --unset-all url.'\(url)'.insteadOf \(repoPath)"
            Shell.execute(command)
            Log.success("移除完成")
            
            // 克隆镜像
            Log.info("开始克隆镜像...")
            Log.info("git clone --mirror \(url)")
            command = "cd \(repoDir) && git clone --mirror \(url)"
            let result = Shell.execute(command)
            if result.status == 0 {
                Log.success("克隆完成")
            } else {
                Log.error(result.results)
                throw SPMError.unreachableRemoteRepo("克隆远程仓库失败")
            }
            
            // 配置 gitconfig
            Log.info("开始进行git配置...")
            command = "git config --local url.'\(url)'.insteadOf \(repoPath)"
            Shell.execute(command)
            Log.success("配置完成")
        }
    }
}
