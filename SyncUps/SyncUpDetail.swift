//
//  SyncUpDetail.swift
//  SyncUps
//
//  Created by tommyhan on 26/6/2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct SyncUpDetail {
    @Reducer(state: .equatable)
    enum Destination {
        case alert(AlertState<Alert>)
        case edit(SyncUpForm)
        @CasePathable
        enum Alert {
            case confirmButtonTapped
        }
    }
    
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared var syncUp: SyncUp
    }
    
    enum Action {
        case cancelEditButtonTapped
        case deleteButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case doneEditingButtonTapped
        case editButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination(.presented(.alert(.confirmButtonTapped))):
                @Shared(.fileStorage(.syncUps)) var syncUps: IdentifiedArrayOf<SyncUp> = []
                syncUps.remove(id: state.syncUp.id)
                return .run { _ in await dismiss() }
                
            case .destination:
                return .none
            case .cancelEditButtonTapped:
                state.destination = nil
                return .none
            case .deleteButtonTapped:
                state.destination = .alert(.deleteSyncUp)
                return .none
            case .doneEditingButtonTapped:
                guard let editedSyncUp = state.destination?.edit?.syncUp
                else { return .none }
                state.syncUp = editedSyncUp
                state.destination = nil
                return .none
            case .editButtonTapped:
                state.destination = .edit(SyncUpForm.State(syncUp: state.syncUp))
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AlertState where Action == SyncUpDetail.Destination.Alert {
    static let deleteSyncUp = Self {
        TextState("Delete?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmButtonTapped) {
            TextState("Yes")
        }
        ButtonState(role: .cancel) {
            TextState("Nevermind")
        }
    } message: {
        TextState("Are you sure you want to delete this meeting?")
    }
}

struct SyncUpDetailView: View {
    @Bindable var store: StoreOf<SyncUpDetail>
    
    var body: some View {
        Form {
            Section {
                NavigationLink(
                    state: AppFeature.Path.record(RecordMeeting.State(syncUp: store.$syncUp))
                ) {
                    Label("Start Meeting", systemImage: "timer")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                    
                }
                HStack {
                    Label("Length", systemImage: "clock")
                    Spacer()
                    Text(store.syncUp.duration.formatted(.units()))
                }
                
                HStack {
                    Label("Theme", systemImage: "paintpalette")
                    Spacer()
                    Text(store.syncUp.theme.name)
                        .padding(4)
                        .foregroundColor(store.syncUp.theme.accentColor)
                        .background(store.syncUp.theme.mainColor)
                        .cornerRadius(4)
                }
            } header: {
                Text("Sync-up Info")
            }
            
            if !store.syncUp.meetings.isEmpty {
                Section {
                    ForEach(store.syncUp.meetings) { meeting in
                        
                        NavigationLink(
                            state: AppFeature.Path.meeting(meeting, syncUp: store.syncUp)
                        ) {
                            HStack {
                                Image(systemName: "calendar")
                                Text(meeting.date, style: .date)
                                Text(meeting.date, style: .time)
                            }
                        }
                    }
                } header: {
                    Text("Past meetings")
                }
            }
            
            Section {
                ForEach(store.syncUp.attendees) { attendee in
                    Label(attendee.name, systemImage: "person")
                }
            } header: {
                Text("Attendees")
            }
            
            Section {
                Button("Delete") {
                    store.send(.deleteButtonTapped)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
            }
        }
        .toolbar {
            Button("Edit") {
                store.send(.editButtonTapped)
            }
        }
        .navigationTitle(Text(store.syncUp.title))
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .sheet(item: $store.scope(state: \.destination?.edit, action: \.destination.edit)) { editSyncUpStore in
            NavigationStack {
                SyncUpFormView(store: editSyncUpStore)
                    .navigationTitle(store.syncUp.title)
                    .toolbar(content: {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                store.send(.cancelEditButtonTapped)
                            }
                        }
                        
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                store.send(.doneEditingButtonTapped)
                            }
                        }
                    })
            }
        }
    }
}

#Preview {
  NavigationStack {
    SyncUpDetailView(
      store: Store(
        initialState: SyncUpDetail.State(
          syncUp: Shared(.mock)
        )
      ) {
        SyncUpDetail()
      }
    )
  }
}
