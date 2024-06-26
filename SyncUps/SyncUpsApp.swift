//
//  SyncUpsApp.swift
//  SyncUps
//
//  Created by tommyhan on 6/6/2024.
//

import ComposableArchitecture
import SwiftUI

@main
struct SyncUpsApp: App {
    @MainActor
    static let store = Store(initialState: SyncUpsList.State()) {
        SyncUpsList()
    }
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SyncupListView(store: Self.store)
            }
        }
    }
}
