//
//  FileContentOperation.swift
//  HGCApp
//
//  Created by Surendra on 29/05/19.
//  Copyright © 2019 HGC. All rights reserved.
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
            let pair = try grpc.perform(GetFileContentParam.init(fileNum), payerAccount.getTransactionBuilder())
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
}
