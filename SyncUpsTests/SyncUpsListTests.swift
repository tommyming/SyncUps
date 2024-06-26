//
//  SyncUpsListTests.swift
//  SyncUpsTests
//
//  Created by tommyhan on 7/6/2024.
//

import ComposableArchitecture
import XCTest

@testable import SyncUps

final class SyncUpsListTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor
    func testDeletion() async {
        let store = TestStore(
            initialState: SyncUpsList.State(
                syncUps: [
                    SyncUp(
                        id: SyncUp.ID(),
                        title: "Point-Free Morning Sync"
                    )
                ]
            )) {
                SyncUpsList()
            }
        
        await store.send(.onDelete([0])) {
            $0.syncUps = []
        }
    }
}
