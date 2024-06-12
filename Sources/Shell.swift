//
//  Shell.swift
//
//
//  Created by lawn on 2024/6/12.
//

import Foundation

struct Shell {
    
    /// 执行 Shell 命令 （会等待执行完成）
    /// - Parameters:
    ///   - command: 命令
    ///   - path: 路径 默认为 "/bind/bash"，即 shell 脚本
    /// - Returns: 运行结果和命令执行标准输出
    @discardableResult
    static func execute(_ command: String, at path: String = "/bin/bash") -> (status: Int, results:String) {
        let task = Process();
        task.executableURL = URL(fileURLWithPath:path)
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        task.environment = environment
        task.arguments = ["-c", command]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = String(data: data, encoding: String.Encoding.utf8)!
        task.waitUntilExit()
        pipe.fileHandleForReading.closeFile()
        return (Int(task.terminationStatus),output)
    }
}
