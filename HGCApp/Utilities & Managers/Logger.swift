//
//  Copyright 2019 Hedera Hashgraph LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

// Enum for showing the type of Log Types
enum LogEvent: String {
    case e = "[‼️]" // error
    case i = "[ℹ️]" // info
    case d = "[💬]" // debug
    case v = "[🔬]" // verbose
    case w = "[⚠️]" // warning
    case s = "[🔥]" // severe
}

class Logger {
    static let instance = Logger()
    let queue : OperationQueue = {
        let q = OperationQueue.init()
            q.maxConcurrentOperationCount = 1
            return q
        }()
    
    var logs : [String] = []
    var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    func log(message: String,
                   event: LogEvent,
                   fileName: String = #file,
                   line: Int = #line,
                   column: Int = #column,
                   funcName: String = #function) {
        
        if loggingEnabled {
            queue.addOperation {
                let log = "\n\(Date().toLogString()) \(event.rawValue)[\(self.sourceFileName(filePath: fileName))]:\(line) \(column) \(funcName) -> \(message)"
                self.logs.append(log)
                print(log)
            }
        }
    }
    
    private func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

internal extension Date {
    func toLogString() -> String {
        return Logger.instance.dateFormatter.string(from: self as Date)
    }
}
