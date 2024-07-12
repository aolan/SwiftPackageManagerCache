//
//  Log.swift
//
//
//  Created by lawn on 2024/6/12.
//

import Foundation
import Rainbow

struct Log {
    
    static func info(_ string: String) {
        print(string.cyan)
    }
    
    static func success(_ string: String) {
        print(string.green)
    }
    
    static func error(_ string: String) {
        print(string.red)
    }
}
