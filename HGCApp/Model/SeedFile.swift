//
//  Copyright 2020 Hedera Hashgraph LLC
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

/**
 Encrypted storage for the seed.
 */
class SeedFile {

    /// Create the seed file and exclude it from being backed up.
    static func create(_ encryptedSeed: Data) -> Bool {
        guard let fileURL = getFileURL() else {
            return false
        }
        if !write(Data(), to: fileURL) {
            return false
        }
        if !excludeFromBackup(fileURL) {
            let _ = delete()
            return false
        }
        if !write(encryptedSeed, to: fileURL) {
            return false
        }
        Logger.instance.log(message: "Wrote seed file", event: .i)
        return true
    }

    /// Read the seed file.
    static func read() -> Data? {
        guard let fileURL = getFileURL() else {
            return .none
        }
        guard let encryptedSeed = read(from: fileURL) else {
            return .none
        }
        return .some(encryptedSeed)
    }

    static func delete() -> Bool? {
        guard let fileURL = getFileURL() else {
            return false
        }
        let deletionResult = delete(fileAt: fileURL)
        return deletionResult
    }

    /**
     Get the URL for the seed file.

     - parameter createDirIfMissing: If the directory for the URL does not exist, create it.
     - returns: The URL for the seed file, or nil if the OS call fails.
     */
    private static func getFileURL(createDirIfMissing: Bool = false) -> URL? {
        do {
            let fm = FileManager.default
            let dir = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: createDirIfMissing)
            Logger.instance.log(message: "URL for directory is: \(dir)", event: .e)
            let fileURL = dir.appendingPathComponent("recphr.bin", isDirectory: false)
            return .some(fileURL)
        }
        catch {
            Logger.instance.log(message: "Unable to find (or create) directory for seed file: \(error)", event: .e)
            return .none
        }
    }

    private static func write(_ data: Data, to url: URL) -> Bool {
        do {
            try data.write(to: url)
            return true
        }
        catch {
            Logger.instance.log(message: "Unable to write seed file: \(error)", event: .e)
            return false
        }
    }

    private static func excludeFromBackup(_ url: URL) -> Bool {
        var fileURL = url
        do {
            var urlResourceValues = URLResourceValues()
            urlResourceValues.isExcludedFromBackup = true
            try fileURL.setResourceValues(urlResourceValues)
            return true
        }
        catch {
            Logger.instance.log(message: "Unable to exclude seed file from backup", event: .e)
            return false
        }
    }

    private static func read(from url: URL) -> Data? {
        do {
            let encryptedSeed = try Data(contentsOf: url)
            return .some(encryptedSeed)
        }
        catch {
            Logger.instance.log(message: "Unable to decrypt seed: \(error)", event: .e)
            return .none
        }
    }

    private static func delete(fileAt url: URL) -> Bool? {
        do {
            let fm = FileManager.default
            try fm.removeItem(at: url)
            return .some(true)
        }
        catch {
            if let cocoaError = error as? CocoaError {
                if cocoaError.code == .fileNoSuchFile {
                    return .some(false)
                }
            }
            Logger.instance.log(message: "Unable to delete seed file", event: .w)
            return .none
        }
    }
}
