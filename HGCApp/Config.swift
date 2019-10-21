//
//  Config.swift
//  HGCApp
//
//  Created by Surendra on 22/09/18.
//  Copyright © 2018 HGC. All rights reserved.
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
