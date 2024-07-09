import ArgumentParser
import Foundation
import FileKit

@main
struct SPM: ParsableCommand {
    /// 镜像仓库缓存路径
    static let cacheDir: String = "\(Path.userCaches)/com.spm.tool/repos_mirror"

    static var configuration = CommandConfiguration(
        commandName: "spm",
        abstract: "swift package manager 镜像工具",
        usage: """
            spm list
            spm add <url>
            spm remove <url>
            spm update <url>
            spm xcode
            sudo spm xcode-select </Application/xcode_xx.app/Contents/Developer>
        """,
        discussion: """
        工具原理：
        1、将 `github` 远程仓库克隆一份镜像到开发者电脑中，默认存在 `~/Library/Caches/com.lawn.spm.tool/repos_mirror` 目录下
        2、修改当前项目的 `git` 配置，在 `.git/config` 文件中，使用 `insteadOf` 将远程仓库替换成本地镜像
        3、然后在项目中执行 `swift package resolve` 和 `swift package reset` 拉取的都是本地镜像的仓库。经过测试，非常稳定，无网也可以
        """,
        subcommands: [List.self, Add.self, Remove.self, Update.self, Xcode.self, XcodeSelect.self],
        defaultSubcommand: SPM.self
    )

    mutating func run() throws {
        Shell.execute("spm -h")
    }
    
    
    /// 将 github 链接转成 URL 类型
    /// - Parameter url: github链接
    /// - Returns: URL类型，如果为 nil，说明外部传入的链接不合法 或 暂不支持
    static func toRemoteURL(_ url: String) -> URL? {
        // 链接不是以 https://github.com 开头的，暂不支持
        if !url.hasPrefix("https://github.com") { return nil }
        // 链接不合法，不支持
        guard let remoteURL = URL(string: url) else { return nil }
        // 链接不是以 .git 为后缀，暂不支持
        if remoteURL.pathExtension != "git" {
            return nil
        }
        return remoteURL
    }
    
    
    /// 将本地镜像仓库路径转成 github 链接
    /// - Parameter path: 本地镜像仓库路径
    /// - Returns: github 链接，如果为 nil，说明用户输入不合法
    static func toRemoteURLString(_ path: String) -> String? {
        if !path.hasPrefix(SPM.cacheDir) {
            return nil
        }
        let localURL = URL(fileURLWithPath: path)
        let count = localURL.pathComponents.count
        if count <= 2 {
            return nil
        }
        guard let repoName = localURL.pathComponents.last else { return nil }
        guard let groupName = localURL.deletingLastPathComponent().pathComponents.last else { return nil }
        return "https://github.com/\(groupName)/\(repoName)"
    }
}
