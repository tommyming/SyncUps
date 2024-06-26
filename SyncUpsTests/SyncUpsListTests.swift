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
    func testAddSyncUp_NonExhaustive() async {
        let store = TestStore(initialState: SyncUpsList.State()) {
            SyncUpsList()
        } withDependencies: { state in
            state.uuid = .incrementing
        }
        
        store.exhaustivity = .off(showSkippedAssertions: true)
        
        await store.send(.addSyncUpButtonTapped)
        
        let editedSyncUp = SyncUp(
            id: SyncUp.ID(0),
            attendees: [
                Attendee(id: Attendee.ID(), name: "Blob"),
                Attendee(id: Attendee.ID(), name: "Blob Jr.")
            ],
            title: "Point-Free morning sync"
        )
        
        await store.send(\.addSyncUp.binding.syncUp, editedSyncUp)
        
        
        await store.send(.confirmAddButtonTapped) {
            $0.syncUps = [editedSyncUp]
        }
    }
    
    
    // MARK: - Exhaustive Version
    @MainActor
    func testAddSyncUp() async {
        let store = TestStore(initialState: SyncUpsList.State()) {
            SyncUpsList()
        } withDependencies: { state in
            state.uuid = .incrementing
        }
        
        await store.send(.addSyncUpButtonTapped) { state in
            state.addSyncUp = SyncUpForm.State(
                syncUp: SyncUp(id: SyncUp.ID(0))
            )
        }
        
        let editedSyncUp = SyncUp(
            id: SyncUp.ID(0),
            attendees: [
                Attendee(id: Attendee.ID(), name: "Blob"),
                Attendee(id: Attendee.ID(), name: "Blob Jr.")
            ],
            title: "Point-Free morning sync"
        )
        
        await store.send(\.addSyncUp.binding.syncUp, editedSyncUp) {
            $0.addSyncUp?.syncUp = editedSyncUp
        }
        
        await store.send(.confirmAddButtonTapped) {
            $0.addSyncUp = nil
//            $0.syncUps = [editedSyncUp]
        }
    }
    
//    @MainActor
//    func testDeletion() async {
//        let store = TestStore(
//            initialState: SyncUpsList.State(
//                syncUps: [
//                    SyncUp(
//                        id: SyncUp.ID(),
//                        title: "Point-Free Morning Sync"
//                    )
//                ]
//            )) {
//                SyncUpsList()
//            }
//        
//        await store.send(.onDelete([0])) {
//            $0.syncUps = []
//        }
//    }
}
