//
//  SPM+Build.swift
//
//
//  Created by lawn.cao on 2024/7/12.
//

import Foundation
import ArgumentParser
import FileKit

extension SPM {
    
    static func clean(project: String, scheme: String, configuration: String) throws {
        Log.info("\n先清理上次编译产生的文件...")
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: SPM.buildDir, isDirectory: &isDir) && isDir.boolValue {
            try FileManager.default.removeItem(atPath: SPM.buildDir)
        }
        Log.success("清理完成\n")
        Log.info("清理编译缓存")
        let command = """
        xcodebuild clean -project \(project) \
        -scheme \(scheme) \
        -configuration \(configuration) \
        -destination 'generic/platform=iOS'
        """
        Log.info("执行命令：\(command)")
        let result = Shell.execute(command)
        if result.status == 0 {
            Log.success("清理完成")
        } else {
            Log.error("清理失败")
            throw SPMError.cleanFailed("清理失败")
        }
    }
    
    static func archive(project: String, scheme: String, configuration: String, activeCompilationConditions: String) throws {
        Log.info("\n开始编译...")
        // 判断编译目录不存在，创建目录
        var isDir: ObjCBool = false
        if !FileManager.default.fileExists(atPath: SPM.buildDir, isDirectory: &isDir) || !isDir.boolValue {
            do {
                Log.info("创建编译目录...")
                try FileManager.default.createDirectory(at: URL(fileURLWithPath: SPM.buildDir), withIntermediateDirectories: true)
            } catch {
                Log.error("创建失败")
                throw SPMError.createDirFailed("编译目录创建失败")
            }
        }
        Log.info("正在归档...")
        let command = """
        xcodebuild archive -project \(project) \
        -scheme \(scheme) \
        -configuration \(configuration) \
        -destination 'generic/platform=iOS' \
        -archivePath \(SPM.buildDir)\(scheme).xcarchive \
        SWIFT_ACTIVE_COMPILATION_CONDITIONS='\(activeCompilationConditions.replacingOccurrences(of: ",", with: " "))'
        """
        Log.info("执行命令：\(command)")
        let result = Shell.execute(command)
        if result.status == 0 {
            Log.success("归档完成")
        } else {
            Log.error("归档失败")
            throw SPMError.archiveScheme("归档失败")
        }
    }
    
    static func export(project: String, scheme: String, configuration: String, exportOptionsPlistPath: String) throws {
        Log.info("\n开始导出ipa文件")
        let command = """
        xcodebuild -exportArchive  \
        -archivePath \(SPM.buildDir)\(scheme).xcarchive \
        -exportPath \(SPM.buildDir) \
        -exportOptionsPlist \(exportOptionsPlistPath)
        """
        Log.info("执行命令：\(command)")
        let result = Shell.execute(command)
        if result.status == 0 {
            Log.success("导出完成：\(SPM.buildDir)")
        } else {
            Log.error("导出失败")
            throw SPMError.exportFailed("清理失败")
        }
    }

    // MARK: 子命令
    struct Build: ParsableCommand {
        static var configuration: CommandConfiguration = CommandConfiguration(commandName: "build", abstract: "打ipa包提供给测试")
        
        @Option(name: .shortAndLong, help: "项目文件，后缀为 .xcodeproj 的文件（暂不支持 xcworkspace)")
        var project: String

        @Option(name: .shortAndLong, help: "待编译的 scheme")
        var scheme: String

        @Option(name: .shortAndLong, help: "取值范围：Release/Debug")
        var configuration: String
        
        @Option(name: .shortAndLong, help: "导出选项文件目录，是一个plist文件")
        var exportOptionsPlistPath: String

        @Option(name: .shortAndLong, help: "Swift条件编译参数，传入方式为 KEY1,KEY2 即多个参数以英文逗号分割，记住改字段会覆盖原有的配置，如果原项目有 DEBUG，就需要加上")
        var activeCompilationConditions: String?

        mutating func run() throws {
            if !project.hasSuffix(".xcodeproj") {
                throw SPMError.invalidProject("项目文件不正确，示例：/path/to/project/demo.xcodeproj")
            }
            if scheme.isEmpty {
                throw SPMError.invalidScheme("Scheme不能为空，若不清楚项目的scheme是什么，尝试执行 xcodebuild -list，在输出的内容底部就有")
            }
            if !FileManager.default.fileExists(atPath: exportOptionsPlistPath) {
                throw SPMError.exportOptionsFileNotFound("未设置导出配置文件")
            }
            try SPM.clean(project: project, scheme: scheme, configuration: configuration)
            try SPM.archive(project: project, scheme: scheme, configuration: configuration, activeCompilationConditions: activeCompilationConditions ?? "")
            try SPM.export(project: project, scheme: scheme, configuration: configuration, exportOptionsPlistPath: exportOptionsPlistPath)
        }
    }
}
