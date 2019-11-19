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

class TransactionBuilder {
    let payerAccount:HGCAccountID
    var node:HGCAccountID = HGCAccountID.init(shardId: 0, realmId: 0, accountId: 0)
    let txnFee:UInt64 = AppConfigService.defaultService.fee
    var credentials:[HGCKeyPairProtocol]

    init(payerCredentials:HGCKeyPairProtocol?, payerAccount:HGCAccountID) {
        self.payerAccount = payerAccount
        if let c = payerCredentials {
            self.credentials = [c]
        } else {
            self.credentials = []
        }
    }

    func addCredentials(_ keyPair:HGCKeyPairProtocol) {
        credentials.append(keyPair)
    }

    func txnBody(memo:String?, fee:UInt64, generateRecord:Bool = false) -> Proto_TransactionBody {
        var txnId = Proto_TransactionID.init()

        txnId.transactionValidStart = Date().timeIntervalSince1970.protoTimestamp()
        txnId.accountID = payerAccount.protoAccountID()

        var txnBody = Proto_TransactionBody.init()
        txnBody.transactionID = txnId
        txnBody.transactionFee = fee
        txnBody.transactionValidDuration = TimeInterval(30).protoDuration()
        txnBody.generateRecord = generateRecord
        txnBody.memo = memo ?? ""
        txnBody.nodeAccountID = node.protoAccountID()
        return txnBody
    }

    func signedTransaction(body:Proto_TransactionBody, dummy:Bool = false, forThirdParty:Bool = false) -> Proto_Transaction {
        if useBetaAPIs {
            var sigMap = Proto_SignatureMap.init()
            var list:[Proto_SignaturePair] = []
            for creds in credentials {
                let sigPair = getSignaturePair(body: body, dummy: dummy, useFullKeyPrefix: forThirdParty, keyPair: creds)
                list.append(sigPair)
                if dummy && forThirdParty {
                    list.append(sigPair)
                    list.append(sigPair)
                }
            }
            sigMap.sigPair = list
            var txn = Proto_Transaction.init()
            txn.bodyBytes = try! body.serializedData()
            txn.sigMap = sigMap
            return txn

        } else {
            var list = Proto_SignatureList.init()
            var sigs:[Proto_Signature] = []
            for creds in credentials {
                let sig = getSignature(body: body, dummy: dummy, keyPair: creds)
                sigs.append(sig)
                sigs.append(sig)
                if dummy && forThirdParty {
                    sigs.append(sig)
                    sigs.append(sig)
                }
            }
            list.sigs = sigs
            var txn = Proto_Transaction.init()
            txn.body = body
            txn.sigs = list
            return txn
        }

    }

    private func getSignaturePair(body:Proto_TransactionBody, dummy:Bool, useFullKeyPrefix:Bool = false, keyPair:HGCKeyPairProtocol) -> Proto_SignaturePair {

        var signature = Proto_SignaturePair.init()
        if let serializedData = try? body.serializedData() {
            let sig = dummy ? Data.init() : keyPair.signMessage(serializedData)!
            signature.ed25519 = sig
        }

        let data = keyPair.publicKeyData!
        if useFullKeyPrefix {
            signature.pubKeyPrefix = data
        } else {
            var values = [UInt8](repeating:0, count:4)
            data.copyBytes(to: &values, count: 4)
            signature.pubKeyPrefix = Data.init(values)

        }
        return signature
    }

    private func getSignature(body:Proto_TransactionBody, dummy:Bool, keyPair:HGCKeyPairProtocol) -> Proto_Signature {
        var signature = Proto_Signature.init()
        if let serializedData = try? body.serializedData() {
            let sig = dummy ? Data.init() : keyPair.signMessage(serializedData)!
            signature.ed25519 = sig
        }

        return signature
    }

    func createQueryHeader(memo:String, queryFee:UInt64, rType:Proto_ResponseType = .answerOnly) -> Proto_QueryHeader {
        var qHeader = Proto_QueryHeader.init()
        var body = txnBody(memo: memo, fee:txnFee)
        body.cryptoTransfer = Proto_CryptoTransferTransactionBody.body(from: payerAccount.protoAccountID(), to: node.protoAccountID(), amount: queryFee)
        qHeader.payment = signedTransaction(body: body)
        qHeader.responseType = rType
        return qHeader
    }
}

class GetTransactionReceiptParam: QueryParams {
    let txnID:Proto_TransactionID
    
    init(_ txnID:Proto_TransactionID) {
        self.txnID = txnID
    }

    func getPayload(_ txnBuilder:TransactionBuilder) -> Proto_Query {
        let qHeader = txnBuilder.createQueryHeader(memo: "for receipt", queryFee: txnBuilder.txnFee)
        var txnGetReceiptQuery = Proto_TransactionGetReceiptQuery.init()
        txnGetReceiptQuery.header = qHeader
        txnGetReceiptQuery.transactionID = txnID
        var query = Proto_Query.init()
        query.transactionGetReceipt = txnGetReceiptQuery
        return query
    }

    func perform(query: Proto_Query, rpc: HAPIRPCProtocol) throws -> Proto_Response {
        return try rpc.cryptoClient.getTransactionReceipts(query)
    }
}

class GetBalanceParam: QueryParams {
    let accountID:HGCAccountID
    init(_ accID:HGCAccountID) {
        self.accountID = accID
    }

    func getPayload(_ txnBuilder: TransactionBuilder) -> Proto_Query {
        let qHeader = txnBuilder.createQueryHeader(memo: "for balance check", queryFee: txnBuilder.txnFee)
        var getBalaceQuery = Proto_CryptoGetAccountBalanceQuery.init()
        getBalaceQuery.header = qHeader
        getBalaceQuery.accountID = accountID.protoAccountID()
        var query = Proto_Query.init()
        query.cryptogetAccountBalance = getBalaceQuery
        return query
    }

    func perform(query: Proto_Query, rpc: HAPIRPCProtocol) throws -> Proto_Response {
        return try rpc.cryptoClient.cryptoGetBalance(query)
    }
}

class UpdateAccountParam: TransactionParams {
    let keyPair:HGCKeyPairProtocol
    init(_ keyPair:HGCKeyPairProtocol) {
        self.keyPair = keyPair
    }

    func getPayload(_ txnBuilder: TransactionBuilder) -> Proto_Transaction {
        var txnBody = txnBuilder.txnBody(memo: "for update account", fee: txnBuilder.txnFee, generateRecord: true)
        var body = Proto_CryptoUpdateTransactionBody.init()
        body.accountIdtoUpdate = txnBuilder.payerAccount.protoAccountID()
        var newKey = Proto_Key.init()
        newKey.ed25519 = keyPair.publicKeyData
        body.key = newKey
        txnBody.cryptoUpdateAccount = body
        txnBuilder.addCredentials(keyPair)
        let txn = txnBuilder.signedTransaction(body: txnBody, dummy: false, forThirdParty: false)
        return txn
    }

    func perform(transaction: Proto_Transaction, rpc: HAPIRPCProtocol) throws -> Proto_TransactionResponse {
        return try rpc.cryptoClient.updateAccount(transaction)
    }
}

class GetFileContentParam: QueryParams {
    let fileNum:Int64
    let fee:UInt64?

    init(_ fileNum:Int64, fee:UInt64? = nil) {
        self.fileNum = fileNum
        self.fee = fee
    }

    func getPayload(_ txnBuilder: TransactionBuilder) -> Proto_Query {
        var fileID = Proto_FileID.init()
        fileID.shardNum = 0
        fileID.realmNum = 0
        fileID.fileNum = fileNum

        let qHeader:Proto_QueryHeader
        if let fee = self.fee {
            qHeader = txnBuilder.createQueryHeader(memo: "for get file content", queryFee: fee)
        } else {
            qHeader = txnBuilder.createQueryHeader(memo: "for get file content fee", queryFee: txnBuilder.txnFee, rType: .costAnswer)
        }
        
        var fileQuery = Proto_FileGetContentsQuery.init()
        fileQuery.header = qHeader
        fileQuery.fileID = fileID
        var query = Proto_Query.init()
        query.fileGetContents = fileQuery
        return query
    }

    func perform(query: Proto_Query, rpc: HAPIRPCProtocol) throws -> Proto_Response {
        return try rpc.fileClient.getFileContent(query)
    }
}

struct CreateAccountParams: TransactionParams {
    let key: HGCPublickKeyAddress
    let amount:UInt64
    let fee:UInt64
    let memo:String

    init(publicKey:HGCPublickKeyAddress, amount:UInt64, memo:String, fee:UInt64) {
        self.key = publicKey
        self.amount = amount
        self.fee = fee
        self.memo = memo
    }

    func getPayload(_ txnBuilder: TransactionBuilder) -> Proto_Transaction {
        var body = Proto_CryptoCreateTransactionBody.init()
        body.key = key.protoKey()
        body.initialBalance = amount
        body.autoRenewPeriod = TimeInterval(7890000).protoDuration()
        var txnBody = txnBuilder.txnBody(memo: memo, fee: fee, generateRecord: true)
        txnBody.cryptoCreateAccount = body
        let txn = txnBuilder.signedTransaction(body: txnBody, dummy: false, forThirdParty: false)
        return txn
    }

    func perform(transaction: Proto_Transaction, rpc: HAPIRPCProtocol) throws -> Proto_TransactionResponse {
        return try rpc.cryptoClient.createAccount(transaction)
    }
}

class GetAccountInfoParam: QueryParams {
    let accountID:HGCAccountID
    let fee:UInt64?
    
    init(_ accountID:HGCAccountID, fee:UInt64? = nil) {
        self.accountID = accountID
        self.fee = fee
    }

    func getPayload(_ txnBuilder: TransactionBuilder) -> Proto_Query {
        let qHeader:Proto_QueryHeader
        if let fee = self.fee {
            qHeader = txnBuilder.createQueryHeader(memo:"for get account info", queryFee: fee)
        } else {
            qHeader = txnBuilder.createQueryHeader(memo:"for get account info cost", queryFee: txnBuilder.txnFee, rType:.costAnswer)
        }
        var getAccountInfoQuery = Proto_CryptoGetInfoQuery.init()
        getAccountInfoQuery.header = qHeader
        getAccountInfoQuery.accountID = accountID.protoAccountID()
        var query = Proto_Query.init()
        query.cryptoGetInfo = getAccountInfoQuery
        return query
    }

    func perform(query: Proto_Query, rpc: HAPIRPCProtocol) throws -> Proto_Response {
        return try rpc.cryptoClient.getAccountInfo(query)
    }
}

class GetAccountRecordParam : QueryParams {
    let accountID:HGCAccountID
    let fee:UInt64?
    init(_ accountID:HGCAccountID, fee:UInt64? = nil) {
        self.accountID = accountID
        self.fee = fee
    }

    func getPayload(_ txnBuilder: TransactionBuilder) -> Proto_Query {
        let qHeader:Proto_QueryHeader
        if let fee = self.fee {
            qHeader = txnBuilder.createQueryHeader(memo:"for account record", queryFee: fee)
        } else {
            qHeader = txnBuilder.createQueryHeader(memo:"for account record cost", queryFee: txnBuilder.txnFee, rType:.costAnswer)
        }
         
        var accRecordQuery = Proto_CryptoGetAccountRecordsQuery.init()
        accRecordQuery.header = qHeader
        accRecordQuery.accountID = accountID.protoAccountID()
        var query = Proto_Query.init()
        query.cryptoGetAccountRecords = accRecordQuery
        return query
    }

    func perform(query: Proto_Query, rpc: HAPIRPCProtocol) throws -> Proto_Response {
        return try rpc.cryptoClient.getAccountRecords(query)
    }
}

class TransferParam: TransactionParams {
    let toAccount:HGCAccountID
    let amount:UInt64
    let notes:String?
    let fee:UInt64
    let forThirdParty:Bool
    let toAccountName:String?

    init(toAccount:HGCAccountID, amount:UInt64, notes:String?, fee:UInt64, forThirdParty:Bool, toAccountName:String? = nil) {
        self.toAccount = toAccount
        self.amount = amount
        self.notes = notes
        self.fee = fee
        self.forThirdParty = forThirdParty
        self.toAccountName = toAccountName
    }

    func getPayload(_ txnBuilder: TransactionBuilder) -> Proto_Transaction {
        var txnBody = txnBuilder.txnBody(memo: notes, fee: fee, generateRecord: true)
        txnBody.cryptoTransfer = Proto_CryptoTransferTransactionBody.body(from: txnBuilder.payerAccount.protoAccountID(), to: toAccount.protoAccountID(), amount: amount)
        let txn = txnBuilder.signedTransaction(body: txnBody, dummy: false, forThirdParty: forThirdParty)
        return txn
    }

    func perform(transaction: Proto_Transaction, rpc: HAPIRPCProtocol) throws -> Proto_TransactionResponse {
        return try rpc.cryptoClient.cryptoTransfer(transaction)
    }
}

extension Proto_CryptoTransferTransactionBody {
    static func body(from: Proto_AccountID, to: Proto_AccountID, amount:UInt64) -> Proto_CryptoTransferTransactionBody {
        var accAmount1 = Proto_AccountAmount.init()
        accAmount1.accountID = from
        accAmount1.amount = -1 * Int64(amount)

        var accAmount2 = Proto_AccountAmount.init()
        accAmount2.accountID = to
        accAmount2.amount = Int64(amount)

        var list = Proto_TransferList.init()
        list.accountAmounts = [accAmount1, accAmount2]

        var body = Proto_CryptoTransferTransactionBody.init()
        body.transfers = list
        return body
    }
}

extension Proto_Transaction {
    func transactionBody() -> Proto_TransactionBody {
        do {
            if !bodyBytes.isEmpty {
                return try Proto_TransactionBody(serializedData: bodyBytes)
            }

        } catch {

        }
        return body
    }
}
