// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest
import Common

class TabTrayTests: BaseTestCase {
    func testAccessibility() throws {
        guard #available(iOS 17.0, *), !skipPlatform else { return }

        waitForTabsButton()
        waitUntilPageLoad()

        // Open Tab Tray
        navigator.goto(TabTray)

        try app.performAccessibilityAudit { issue in
            var shouldIgnore = false

            // ignore text clipped issue for the tab cell title
            if let element = issue.element,
               element.elementType == .staticText,
               element.label.contains("Homepage"),
               issue.auditType == .textClipped {
                shouldIgnore = true
            }
            return shouldIgnore
        }
    }

    // https://mozilla.testrail.io/index.php?/cases/view/2306867
    func testCloseOneTab() {
        // Open a few tabs
        waitForTabsButton()
        navigator.openURL("http://localhost:\(serverPort)/test-fixture/find-in-page-test.html")
        waitUntilPageLoad()
        navigator.createNewTab()
        navigator.openURL("http://localhost:\(serverPort)/test-fixture/test-example.html")
        waitUntilPageLoad()
        navigator.createNewTab()
        navigator.openURL("localhost:\(serverPort)/test-fixture/test-mozilla-org.html")
        waitUntilPageLoad()
        navigator.goto(TabTray)

        // Experiment from #25337: "Undo" button no longer available on iPhone.
        if iPad() {
            // Tap "x"
            app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_2"].buttons[StandardImageIdentifiers.Large.cross].tap()
            mozWaitForElementToNotExist(app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_2"])
            app.buttons["Undo"].waitAndTap()
            mozWaitForElementToExist(app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_2"])

            // Long press tab. Tap "Close Tab" from the context menu
            app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_2"].press(forDuration: 2)
            mozWaitForElementToExist(app.collectionViews.buttons["Close Tab"])
            app.collectionViews.buttons["Close Tab"].waitAndTap()
            mozWaitForElementToNotExist(app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_2"])
            app.buttons["Undo"].waitAndTap()
            mozWaitForElementToExist(app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_2"])

            // Swipe tab
            app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_2"].swipeLeft()
            mozWaitForElementToNotExist(app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_2"])
            app.buttons["Undo"].waitAndTap()
            mozWaitForElementToExist(app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_2"])
        } else {
            // Tap "x"
            app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_2"]
                .buttons[AccessibilityIdentifiers.TabTray.closeButton].waitAndTap()
            mozWaitForElementToNotExist(app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_2"])

            // Long press tab. Tap "Close Tab" from the context menu
            app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_1"].press(forDuration: 2)
            mozWaitForElementToExist(app.collectionViews.buttons["Close Tab"])
            app.collectionViews.buttons["Close Tab"].waitAndTap()
            mozWaitForElementToNotExist(app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_2"])

            // Swipe tab
            app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_0"].swipeLeft()
            mozWaitForElementToNotExist(app.cells[AccessibilityIdentifiers.TabTray.tabCell+"_1_0"])
        }
    }
}
