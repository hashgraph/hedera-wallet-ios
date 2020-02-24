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

import XCTest
@testable import HGCApp

/// Unit tests for the ExchangeInfo class.
class ExchangeInfoTests: XCTestCase {

    //
    // Tests of this struct are bare-bones.  This struct was selected for simplicity of writing the first unit test
    // which does not depend on any significant components.  However, it is clear that the structure is part of a
    // system that would benefit from significant refactoring.  A refactor likely would significantly change this
    // structure, if it survives.  Therefore, only some simple tests are added.
    //

    func testIdealQRCode() {

        let idealQRCodeString = "Treasury,http://www.hedera.com,8080,0.0.2,Note"
        let expectedExchangeInfo = ExchangeInfo(
            accountID: HGCAccountID(shardId: 0, realmId: 0, accountId: 2),
            name: "Treasury",
            host: "http://www.hedera.com:8080",
            memo: .some("Note"))

        let actualExchangeInfo = ExchangeInfo.fromQRCode(idealQRCodeString)

        XCTAssertEqual(.some(expectedExchangeInfo), actualExchangeInfo)
    }

    func testQRCodeNoNote() {

        let noNoteQRCodeString = "Treasury,http://www.hedera.com,8080,0.0.2"
        let expectedExchangeInfo = ExchangeInfo(
            accountID: HGCAccountID(shardId: 0, realmId: 0, accountId: 2),
            name: "Treasury",
            host: "http://www.hedera.com:8080",
            memo: .none)

        let actualExchangeInfo = ExchangeInfo.fromQRCode(noNoteQRCodeString)

        XCTAssertEqual(.some(expectedExchangeInfo), actualExchangeInfo)
    }

    func testIdealHTTPURLString() {

        let idealHTTPURLString = "http://www.example.com"
        let expectedURL = URL.init(string: idealHTTPURLString)

        let actualURL = ExchangeInfo.toHttpURL(host: idealHTTPURLString)

        XCTAssertEqual(expectedURL, actualURL)
    }

    func testIdealHTTPSURLString() {

        let idealHTTPSURLString = "https://www.example.com"
        let expectedURL = URL.init(string: idealHTTPSURLString)

        let actualURL = ExchangeInfo.toHttpURL(host: idealHTTPSURLString)

        XCTAssertEqual(expectedURL, actualURL)
    }

    func testHTTPURLFromStringWithNoScheme() {

        let idealHTTPURLString = "www.example.com"
        let expectedURL: URL? = URL(string: "http://" + idealHTTPURLString)

        let actualURL = ExchangeInfo.toHttpURL(host: idealHTTPURLString)

        XCTAssertEqual(expectedURL, actualURL)
    }
}
