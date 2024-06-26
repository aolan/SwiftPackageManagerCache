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
    
    struct Xcode: ParsableCommand {
        
        static var configuration: CommandConfiguration = CommandConfiguration(commandName: "xcode", abstract: "查看mac电脑上安装了几个xcode版本")
        
        mutating func run() throws {
            let xcodeDirs = Path("/Applications").find(searchDepth: 1) { path in
                let fileName = path.fileName
                let regex = try! NSRegularExpression(pattern: "xcode", options: .caseInsensitive)
                let matches = regex.matches(in: fileName, range: NSRange(fileName.startIndex..., in: fileName))
                return matches.count > 0
            }
            if xcodeDirs.count == 0 {
                Log.success("您的电脑可能没有安装xcode，或者xcode被修改为其他名字了")
                return
            }
            
            let results = Shell.execute("xcode-select --print-path").results
            
            Log.info("查询到的xcode版本路径如下：")
            for xcodeDir in xcodeDirs {
                let path = Path("\(xcodeDir.rawValue)/Contents/Developer")
                if path.isDirectory && path.exists {
                    if results.hasPrefix(path.rawValue) {
                        Log.success("\(path.rawValue)(default)")
                    } else {
                        Log.success(path.rawValue)
                    }
                }
            }
        }
    }
    
    struct XcodeSelect: ParsableCommand {
        
        static var configuration: CommandConfiguration = CommandConfiguration(commandName: "xcode-select",
                                                                              abstract: "设置默认使用的xcode版本，需要以 sudo 来执行此条命令")
        
        @Argument(help: "Xcode路径，示例：/Applications/Xcode.app/Contents/Developer")
        var path: String
        
        mutating func run() throws {
            let command = "xcode-select --switch \(path)"
            if Shell.execute(command).status == 0 {
                Log.success("切换完成，当前采用的版本是：")
                Log.success(Shell.execute("xcode-select --print-path").results)
            }
            print()
        }
    }
}
