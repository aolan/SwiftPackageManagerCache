//
//  SPM.swift
//
//
//  Created by lawn on 2024/6/12.
//

import ArgumentParser
import Foundation
import FileKit

@main
struct SPM: ParsableCommand {
    /// 镜像仓库缓存路径
    static let cacheDir: String = "\(Path.userCaches)/com.spm.tool/repos_mirror/"
    /// 远程仓库前缀
    static let remoteRepoScheme: String = "https://"
    /// 编译文件存放目录
    static let buildDir: String = "\(Path.userDesktop)/spm-build/"

    static var configuration = CommandConfiguration(
        commandName: "spm",
        abstract: "swift package manager 镜像工具",
        usage: """
            spm list
            spm search <repo_name>
            spm add <url>
            spm remove <url>
            spm update <url>
            spm xcode
            sudo spm xcode-select </Application/xcode_xx.app/Contents/Developer>
            spm build -p <project> -s <scheme> -c <configuration> -e <export-options-plist-path> [-a <active-compilation-conditions>]
        """,
        discussion: """
        一、SPM缓存原理：
            1、将 github 远程仓库克隆一份镜像到开发者电脑中，默认存在 ~/Library/Caches/com.spm.tool/repos_mirror 目录下
            2、修改当前项目的 git 配置，在 .git/config 文件中，使用 insteadOf 将远程仓库替换成本地镜像
            3、然后在项目中执行 swift package resolve 和 swift package reset 拉取的都是本地镜像的仓库。经过测试，非常稳定，无网也可以
        
        二、切换 xcode 版本：
            1、实际调用的是 xcode-select 的方法实现的
        
        三、编译项目：
            涵盖 clean、archive、export 整套流程
        """,
        subcommands: [List.self, Add.self, Remove.self, Update.self, Search.self, Xcode.self, XcodeSelect.self, Build.self],
        defaultSubcommand: SPM.self
    )

    mutating func run() throws {
        Shell.execute("spm -h")
    }
    
    
    /// 验证远程仓库链接是否合法
    /// - Parameter url: 远程仓库链接
    /// - Returns: 是否合法
    static func validateRemoteUrl(_ url: String) -> Bool {
        // 链接不是以 https:// 开头的，暂不支持
        if !url.hasPrefix(SPM.remoteRepoScheme) { return false }
        // 链接不合法，不支持
        guard let remoteURL = URL(string: url) else { return false }
        // 链接不是以 .git 为后缀，暂不支持
        if remoteURL.pathExtension != "git" { return false }
        return true
    }
    
    /// 将本地镜像仓库路径转成远程仓库链接
    /// - Parameter path: 本地镜像仓库路径
    /// - Returns: 远程仓库链接，如果为 nil，说明用户输入不合法
    static func toRemoteURLString(_ path: String) -> String? {
        if !path.hasPrefix(SPM.cacheDir) {
            return nil
        }
        let url = path.replacingOccurrences(of: SPM.cacheDir, with: SPM.remoteRepoScheme)
        Log.info("remote url is: \(url)")
        return url
    }
    
    /// 将远程仓库链接映射到本地路径
    /// - Parameter url: 远程仓库链接
    /// - Returns: 返回本地路径
    static func toLocalPath(_ url: String) -> String {
        return url.replacingOccurrences(of: SPM.remoteRepoScheme, with: SPM.cacheDir)
    }
}
