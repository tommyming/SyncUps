//
//  RecordMeetingTests.swift
//  SyncUpsTests
//
//  Created by tommyhan on 27/6/2024.
//

import XCTest
import ComposableArchitecture

@testable import SyncUps

final class RecordMeetingTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor
    func testTimerFinishes() async {
        let dismissed = self.expectation(description: "dismissed")

        let clock = TestClock()
        let syncUp = SyncUp(
            id: SyncUp.ID(),
            attendees: [
                Attendee(id: Attendee.ID(), name: "Blob"),
                Attendee(id: Attendee.ID(), name: "Blob Jr"),
            ],
            duration: .seconds(4),
            title: "Morning Sync"
        )
        
        let store = TestStore(
            initialState: RecordMeeting.State(syncUp: Shared(syncUp))
        ) {
            RecordMeeting()
        } withDependencies: {
            $0.continuousClock = clock
            $0.date.now = Date(timeIntervalSince1970: 1234567890)
            $0.uuid = .incrementing
            $0.dismiss = DismissEffect { dismissed.fulfill() }
        }
        
        let onAppearTask = await store.send(.onAppear)
        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick) {
            $0.secondsElapsed = 1
        }
        
        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick) { state in
            state.speakerIndex = 1
            state.secondsElapsed = 2
        }
        
        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick) { state in
            state.secondsElapsed = 3
        }
        
        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick) {
            $0.secondsElapsed = 4
            $0.syncUp.meetings.insert(
                Meeting(
                    id: UUID(0),
                    date: Date(timeIntervalSince1970: 1234567890),
                    transcript: ""
                ),
                at: 0
            )
        }
        
        await onAppearTask.cancel()
        await self.fulfillment(of: [dismissed], timeout: 0)
    }

}
