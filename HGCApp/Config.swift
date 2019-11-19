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

let bundleInfo = Bundle.main.infoDictionary!
let appEnv = bundleInfo["HGCAPP_ENVIRONMENT"] as! String
let isDevMode = appEnv.uppercased().contains("DEVELOPMENT")
let allowEditingNet = true
let nodeListFileName = isDevMode ? "nodes-testnet.json" : "nodes-mainnet.json"
let feeScheduleFile = "feeScheduleproto.txt"
let loggingEnabled = true
let portalFAQRestoreAccount = "https://help.hedera.com/hc/en-us/articles/360000714658"
let useBetaAPIs = true // SignatureMap and bodyBytes

let fileNumAddressBook:Int64 = 101
let fileNumFeeSchedule:Int64 = 102

let defaultFee:UInt64 = 50000000
let defaultPort:Int32 = 50211
let termsAndConditions = "https://www.hedera.com/terms"
let privacyPolicy = "https://www.hedera.com/privacy"

let maxAllowedMemoLength = 100

let bitrex = "https://api.bittrex.com/api/v1.1/public/getticker?market=USD-HBAR"
let liquid = "https://api.liquid.com/products/557"
let okcoin = "https://www.okcoin.com/api/spot/v3/instruments/HBAR-USD/ticker"
