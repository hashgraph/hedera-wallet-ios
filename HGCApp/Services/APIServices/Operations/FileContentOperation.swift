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

import UIKit

class FileContentOperation: BaseOperation {
    let payerAccount:HGCAccount
    let fileNum:Int64
    var fileContent:Data? = nil

    init(payerAccount:HGCAccount, fileNum:Int64) {
        self.payerAccount = payerAccount
        self.fileNum = fileNum
    }
    
    override func main() {
        super.main()
        getFileContent()
    }
    
    private func getFileContent() {
        do {
            let cost = try fetchCost(payerAccount)
            let pair = try grpc.perform(GetFileContentParam.init(fileNum, fee: cost), payerAccount.getTransactionBuilder())
            let status = pair.response.fileGetContents.header.nodeTransactionPrecheckCode
            switch status {
            case .ok:
                fileContent = pair.response.fileGetContents.fileContents.contents
           
            default:
                errorMessage = status.getErrorMessage()
                Logger.instance.log(message:status.getErrorMessage(), event: .e)
            }
            
        } catch {
            errorMessage = desc(error)
            Logger.instance.log(message:desc(error), event: .e)
        }
    }
    
    private func fetchCost(_ payerAccount:HGCAccount) throws -> UInt64 {
        let pair = try grpc.perform(GetFileContentParam.init(fileNum), payerAccount.getTransactionBuilder())
               let status = pair.response.fileGetContents.header.nodeTransactionPrecheckCode
        switch status {
        case .ok:
            return pair.response.fileGetContents.header.cost
        default:
            throw status.getErrorMessage()
        }
    }
}
