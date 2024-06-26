//
//  SyncUpDetailTests.swift
//  SyncUpsTests
//
//  Created by tommyhan on 26/6/2024.
//

import ComposableArchitecture
import XCTest

@testable import SyncUps

final class SyncUpDetailTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor
    func testEdit() async {
        let syncUp = SyncUp(
            id: SyncUp.ID(),
            title: "Point-Free Morning Sync"
        )
        
        let store = TestStore(initialState: SyncUpDetail.State(syncUp: Shared(syncUp))) {
            SyncUpDetail()
        }
        
        await store.send(.editButtonTapped) { state in
            state.destination = .edit(SyncUpForm.State(syncUp: syncUp))
        }
        
        var editedSyncUp = syncUp
        editedSyncUp.title = "Point-Free Eventing Sync"
        
        await store.send(\.destination.edit.binding.syncUp, editedSyncUp) { state in
            state.destination?.edit?.syncUp = editedSyncUp
        }
        
        await store.send(.doneEditingButtonTapped) {
            $0.destination = nil
            $0.syncUp = editedSyncUp
        }
    }

}
