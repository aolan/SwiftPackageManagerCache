//
//  Log.swift
//
//
//  Created by lawn on 2024/6/12.
//

import Foundation

struct Log {
    
    private static let INFO = "$(tput setaf 5)"
    private static let SUCCESS = "$(tput setaf 2)"
    private static let ERROR = "$(tput setaf 1)"
    private static let TAIL = "$(tput sgr0)"

    static func info(_ string: String) {
        let content = INFO + string + TAIL
        print(Shell.execute("echo -e \(content)").results)
    }
    
    static func success(_ string: String) {
        let content = SUCCESS + "'" + string + "'" + TAIL
        print(Shell.execute("echo -e \(content)").results)
    }
    
    static func error(_ string: String) {
        let content = ERROR + string + TAIL
        print(Shell.execute("echo -e \(content)").results)
    }
}
