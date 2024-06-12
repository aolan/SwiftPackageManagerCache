//
//  SPMError.swift
//
//
//  Created by lawn on 2024/6/12.
//

import Foundation

enum SPMError: Error {
    // 远程仓库链接不合法
    case invaildRemoteRepo(String)
    // 本地镜像路径不合法
    case invaildLocalRepo(String)
    // 创建路径失败
    case createDirFailed(String)
    // 删除仓库失败
    case deleteLocalRepoFailed(String)
    // 无法访问远程仓库
    case unreachableRemoteRepo(String)
    // 其他错误
    case other(String)
}
