//
//  AppFeatureTests.swift
//  SyncUpsTests
//
//  Created by tommyhan on 27/6/2024.
//

import ComposableArchitecture
import XCTest

@testable import SyncUps

final class AppFeatureTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor
    func testDelete() async throws {
        let syncUp = SyncUp.mock
        @Shared(.syncUps) var syncUps = [syncUp]
        
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        
        let sharedSyncUp = try XCTUnwrap($syncUps[id: syncUp.id])
        
        await store.send(\.path.push, (id: 0, .detail(SyncUpDetail.State(syncUp: sharedSyncUp)))) { state in
            state.path[id: 0] = .detail(SyncUpDetail.State(syncUp: sharedSyncUp))
        }
        
        await store.send(\.path[id:0].detail.deleteButtonTapped) { state in
            state.path[id:0]?.detail?.destination = .alert(.deleteSyncUp)
        }
        
        await store.send(\.path[id:0].detail.destination.alert.confirmButtonTapped) { state in
            state.path[id:0, case: \.detail]?.destination = nil
            state.syncUpsList.syncUps = []
        }
        
        await store.receive(\.path.popFrom) { state in
            state.path = StackState()
        }
    }
}
