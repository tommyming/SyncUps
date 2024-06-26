//
//  SyncUpsFormTests.swift
//  SyncUpsTests
//
//  Created by tommyhan on 7/6/2024.
//

import ComposableArchitecture
import XCTest

@testable import SyncUps

final class SyncUpsFormTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - Remove
    @MainActor
    func testRemoveAttendee() async {
        let store = TestStore(
            initialState: SyncUpForm.State(
                syncUp: SyncUp(
                    id: SyncUp.ID(),
                    attendees: [
                        Attendee(id: Attendee.ID()),
                        Attendee(id: Attendee.ID())
                    ]
                )
            )
        ) {
            SyncUpForm()
        }
        
        await store.send(.onDeleteAttendees([0])) { state in
            state.syncUp.attendees.removeFirst()
        }
    }
    
    @MainActor
    func removeFocusedAttendee() async {
        let attendee1 = Attendee(id: Attendee.ID())
        let attendee2 = Attendee(id: Attendee.ID())
        
        let store = TestStore(
            initialState: SyncUpForm.State(
                syncUp: SyncUp(
                    id: SyncUp.ID(),
                    attendees: [attendee1, attendee2]
                )
            )
        ) {
            SyncUpForm()
        }
        
        await store.send(.onDeleteAttendees([0])) {
            $0.focus = .attendee(attendee2.id)
            $0.syncUp.attendees = [attendee2]
        }
    }
    
    // MARK: - Add
    @MainActor
    func testAddAttendee() async {
        let store = TestStore(
            initialState: SyncUpForm.State(
                syncUp: SyncUp(
                    id: SyncUp.ID()
                )
            )
        ) {
            SyncUpForm()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        
        await store.send(.addAttendeeButtonTapped) {
            $0.focus = .attendee(Attendee.ID(0))
            $0.syncUp.attendees.append(Attendee(id: Attendee.ID(0)))
        }
    }
}
