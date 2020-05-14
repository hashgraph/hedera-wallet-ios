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

import XCTest

/**
 Tests for the Onboard Existing path.

 For these tests, a account has been fully created prior to the test.  The test pathway starts from a fresh install, continues through the user supplying information for the
 fully created account, and at the latest ends when all account information has been loaded and the account overview page is reached.  (Note that additional screens
 may be viewed after this to confirm the resulting state.)
 */
class OnboardExistingTests: XCTestCase {

    /// The recovery phrase expected to be linked to the primary account.
    private var expectedRecoveryPhrase: String? = Optional.none

    /// The account ID expected to be in the wallet.
    private var expectedAccountID: String? = Optional.none

    /// The public key for the above account ID.
    private var expectedPublicKey: String? = Optional.none

    /// The balance of the account with the above ID.
    private var expectedAccountBalance: UInt64? = Optional.none

    /**
     Framework-internal setup to start from a fresh install state.

     - Note: See inside the function for comments describing actions that need to be performed outside of this script for correct test execution.
     */
    override func setUp() {
        super.setUp()

        // External step: Clear app data
        //
        // The application execution should proceed as if execution were occurring after a fresh install.  There are
        // two methods to do this.
        //
        //      1. Uninstall the app
        //      -- OR --
        //      2. Remove app data
        //          2a. Request that the app remove its data locally.
        //              This is done by running the application and selecting the 'Master Reset' option.
        //          2b. Delete the app data directory for the simulator.
        //              The directory follows the below pattern:
        //                  /Users/<user_name>/Library/Developer/CoreSimulator/Devices/<device_uuid>/ \
        //                      data/Containers/Data/Application/<app_uuid>
        //              This step should be taken while the simulator is SHUT DOWN.  It'll be quite upset if the
        //              directory disappears during execution.

        // External environment variable: EXISTING_ACCOUNT_RECOVERY_PHRASE
        //
        // The application will load an account ID linked to a ED25519 seed derived via BIP32 from a mnemonic via
        // BIP39.  We refer to the mnemonic as a "recovery phrase".
        expectedRecoveryPhrase = ProcessInfo.processInfo.environment["EXISTING_ACCOUNT_RECOVERY_PHRASE"]

        // External environment variable: EXISTING_ACCOUNT_ID
        //
        // The application will load an account ID.
        expectedAccountID = ProcessInfo.processInfo.environment["EXISTING_ACCOUNT_ID"]

        // External environment variable: EXISTING_ACCOUNT_PUBLIC_KEY
        //
        // The application will load an account ID whose signatures can be verified with this public key.
        expectedPublicKey = ProcessInfo.processInfo.environment["EXISTING_ACCOUNT_PUBLIC_KEY"]

        // External environment variable: EXISTING_ACCOUNT_BALANCE
        //
        // The application will retrieve the balance of the account matching a loaded account ID.
        do {
            let expectedAccountBalanceText = ProcessInfo.processInfo.environment["EXISTING_ACCOUNT_BALANCE"]
            expectedAccountBalance = expectedAccountBalanceText.flatMap(UInt64.init)
        }

        continueAfterFailure = false
        XCUIApplication().launch()
    }

    /// Convert a decimal HBAR value into tinybars.
    private func tinybars(from hbarDecimalText: String) -> UInt64 {
        let parts = hbarDecimalText.split(separator: ".")
        XCTAssertGreaterThan(parts.count, 0)
        let wholePart = UInt64(parts[0])
        let tinyPart: UInt64
        if parts.count > 1 {
            let length = parts[1].count
            let textValue = UInt64(parts[1])
            XCTAssertNotNil(textValue)
            XCTAssertLessThanOrEqual(length, 8)
            var adjustedValue = textValue!
            for _ in 0..<(8 - length) {
                adjustedValue = adjustedValue * 10
            }
            tinyPart = adjustedValue
        }
        else {
            tinyPart = 0
        }
        XCTAssertNotNil(wholePart)
        return wholePart! * 100_000_000 + tinyPart
    }

    /**
     Get the main window for the app.

     Exclude view searches to the main window to ensure that the views are actually part of the target view hierarchy.

     - Precondition: The app is expected to always have a main window when running.  That window must have the identifier, "MainWindow".
     */
    private func getMainWindow() -> XCUIElement {
        let window = XCUIApplication().windows["Main Window"]
        XCTAssert(window.exists)
        return window
    }

    /**
     Get the root view of an active view controller's view hierarchy from within the active window.

     Exclude view searches to a specific view controller to shrink teh search space and avoid potential naming conflicts.
     */
    private func getRootView(in window: XCUIElement, forVCNamed vcName: String) -> XCUIElement {
        // Note: Root views aren't in any particular category because they are UIView and not a subclass.
        let matches = window.descendants(matching: .other).matching(identifier: vcName + " View Root")
        // Note: this may also occur during development before all view controller root views are labeled.
        XCTAssertEqual(matches.count, 1, "Test failure: not in \(vcName) View Controller.")
        return matches.firstMatch
    }

    /// Get a view within another view.
    private func getView(within view: XCUIElement,
                         named name: String = "",
                         ofType type: XCUIElement.ElementType = .any) -> XCUIElement {
        var matches = view.descendants(matching: type)
        matches = name != "" ? matches.matching(identifier: name) : matches
        XCTAssertEqual(matches.count, 1, "Test failure: view " + (name != "" ? "\"\(name)\" " : "") + "not found.")
        return matches.firstMatch
    }

    /// Dismiss the keyboard if one is present.
    private func dismissKeyboard() {
        let button = XCUIApplication().toolbars.buttons["Dismiss Keyboard"]
        if (button.exists) {
            button.tap()
        }
    }

    /// Test the ideal user path through the Onboard Existing process.
    func testIdealUserPath() {

        // Steps on Wallet Setup Options screen.
        do {
            // Validation: first screen must be Wallet Setup Options.
            let window = getMainWindow()
            let rootView = getRootView(in: window, forVCNamed: "Wallet Setup Options")

            // User action: tap the button representing the onboard existing path.
            let nextStepButton = getView(within: rootView, named: "Onboard Existing Account", ofType: .button)
            nextStepButton.tap()
        }

        // Steps on Backup Wallet screen.
        do {
            // Validation: screen must be Backup Wallet.
            let window = getMainWindow()
            let rootView = getRootView(in: window, forVCNamed: "Backup Wallet")

            // User action: enter recovery phrase.
            let recoveryPhraseEntryField = getView(within: rootView, named: "Backup Phrase Text View",
                                                   ofType: .textView)
            recoveryPhraseEntryField.tap()
            XCTAssertNotNil(expectedRecoveryPhrase)
            recoveryPhraseEntryField.typeText(expectedRecoveryPhrase!)
            dismissKeyboard()

            // User action: tap the button representing the continuation path.
            let nextButton = getView(within: rootView, named: "Backup Phrase Done")
            nextButton.tap()
        }

        // Steps on Restore Account ID screen.
        do {
            // Validation: screen must be Restore Account ID.
            let window = getMainWindow()
            let rootView = getRootView(in: window, forVCNamed: "Restore Account ID")

            // User action: enter account ID.
            let accountIDEntryField = getView(within: rootView, named: "Restore Account ID Text Field",
                                              ofType: .textField)
            accountIDEntryField.tap()
            XCTAssertNotNil(expectedAccountID, "Environment failure")
            accountIDEntryField.typeText(expectedAccountID!)
            dismissKeyboard()

            // User action: tap the button representing the continuation path.
            let nextButton = getView(within: rootView, named: "Restore Account ID Done")
            nextButton.tap()
        }

        sleep(20)
        // Steps on Wallet Restored Successfully alert.
        do {
            // Validation: confirm there is an alert
            let alerts = XCUIApplication().alerts
            XCTAssertEqual(alerts.count, 1)
            let alert = alerts.firstMatch

            // Validation: confirm this is the successful alert
            XCTAssertEqual(alert.label, "Wallet restored successfully")

            // User action: dismiss the alert.
            let buttons = alert.buttons
            XCTAssertEqual(buttons.count, 1)
            let button = buttons.firstMatch
            button.tap()
        }

        // Steps on Security Setup Options screen.
        do {
            // Validation: screen must be Security Setup Options.
            let window = getMainWindow()
            let rootView = getRootView(in: window, forVCNamed: "Security Setup Options")

            // User action: tap the button representing the PIN entry path.
            let nextButton = getView(within: rootView, named: "Security PIN")
            nextButton.tap()
        }

        // Steps on PIN Entry screen (enter new PIN, then confirm new PIN).
        for _ in 0 ..< 2 {
            let pinOne = XCUIApplication().descendants(matching: .any).matching(NSPredicate(format: "label == '1'"))
            XCTAssertEqual(pinOne.count, 1)
            for _ in 0 ..< 4 {
                pinOne.firstMatch.tap()
            }
            let done = XCUIApplication().descendants(matching: .any).matching(NSPredicate(format: "label == 'OK'"))
            done.firstMatch.tap()
        }

        // Steps on Overview screen.
        do {
            // Validation: screen must be Overview.
            let window = getMainWindow()
            let rootView = getRootView(in: window, forVCNamed: "Overview")

            // User action: refresh account information.
            do {
                let spinnerQuery = XCUIApplication().descendants(matching: .progressIndicator)
                let spinnerExists = NSPredicate(format: "exists = true")
                let spinnerMissing = NSPredicate(format: "exists = false")
                let expectSpinnerExists = expectation(for: spinnerExists, evaluatedWith: spinnerQuery, handler: nil)
                let refreshButton = getView(within: window, named: "Refresh")
                refreshButton.tap()
                let resultAppeared = XCTWaiter().wait(for: [expectSpinnerExists], timeout: 1)
                if resultAppeared == .completed {
                    let expectSpinnerMissing = expectation(for: spinnerMissing, evaluatedWith: spinnerQuery, handler: nil)
                    let resultDisappeared = XCTWaiter().wait(for: [expectSpinnerMissing], timeout: 7)
                    XCTAssertEqual(resultDisappeared, .completed)
                }
            }

            // User action: read account balance.
            let balanceView = getView(within: rootView, named: "Account Balance")
            let balanceText = balanceView.label
            print("Account balance (text): " + balanceText)
            let _: UInt64 = tinybars(from: balanceText)

            // Validation: check account balance matches.
            // FIXME: This is hard for the environment to calculate because the amount shown will be AFTER the
            // transaction that links the account.  Each linkage costs HBAR, but the amount can change over time.
            //XCTAssertNotNil(expectedAccountBalance, "Environment failure")
            //XCTAssertEqual(actualBalance, expectedAccountBalance!)

            // User action: open side menu.
            let sideMenuButton = getView(within: window, named: "Side Menu Button", ofType: .button)
            sideMenuButton.tap()

            // User action: open account details.
            let accountDetailsCell = getView(within: window, named: "Default Account Cell", ofType: .cell)
            accountDetailsCell.tap()
        }

        // Steps in Account Details screen.
        do {
            // Validation: screen must be Account Details.
            let window = getMainWindow()
            let rootView = getRootView(in: window, forVCNamed: "Account Details")

            // User action: read account ID.
            let accountIDView = getView(within: rootView, named: "Account ID", ofType: .textField)
            let actualAccountID = accountIDView.value as? String ?? ""

            // Validation: check account ID matches.
            XCTAssertNotNil(expectedAccountID, "Environment failure")
            XCTAssertEqual(actualAccountID, expectedAccountID)

            // User action: read account public key.
            let accountPublicKeyView = getView(within: rootView, named: "Public Key", ofType: .staticText)
            let actualPublicKey = accountPublicKeyView.label

            // Validation: check public key matches.
            XCTAssertNotNil(expectedPublicKey, "Environment failure")
            XCTAssertEqual(actualPublicKey, expectedPublicKey)
        }
    }
}
