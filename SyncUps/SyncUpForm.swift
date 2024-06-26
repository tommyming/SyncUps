//
//  SyncUpForm.swift
//  SyncUps
//
//  Created by tommyhan on 7/6/2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct SyncUpForm {
    @ObservableState
    struct State: Equatable {
        var focus: Field? = .title
        var syncUp: SyncUp
        
        enum Field: Hashable {
            case attendee(Attendee.ID)
            case title
        }
    }
    
    enum Action: BindableAction {
        case addAttendeeButtonTapped
        case binding(BindingAction<State>)
        case onDeleteAttendees(IndexSet)
    }
    
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case let .onDeleteAttendees(indices):
                state.syncUp.attendees.remove(atOffsets: indices)
                guard !state.syncUp.attendees.isEmpty,
                      let firstIndex = indices.first
                else { return .none }
                let index = min(firstIndex, state.syncUp.attendees.count - 1)
                state.focus = .attendee(state.syncUp.attendees[index].id)
                return .none
                
            case .addAttendeeButtonTapped:
                let attendee = Attendee(id: uuid())
                state.syncUp.attendees.append(attendee)
                state.focus = .attendee(attendee.id)
                
                return .none
            }
        }
    }
}

struct SyncUpFormView: View {
    @Bindable var store: StoreOf<SyncUpForm>
    @FocusState var focus: SyncUpForm.State.Field?
    
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $store.syncUp.title)
                    .focused($focus, equals: .title)
                HStack {
                    Slider(value: $store.syncUp.duration.minutes, in: 5...30, step: 1) {
                        Text("Length")
                    }
                    Spacer()
                    Text(store.syncUp.duration.formatted(.units()))
                }
                ThemePicker(selection: $store.syncUp.theme)
            } header: {
                Text("Sync-up Info")
            }
            Section {
                ForEach($store.syncUp.attendees) { $attendee in
                    TextField("Name", text: $attendee.name)
                        .focused($focus, equals: .attendee($attendee.id))
                }
                .onDelete(perform: { indexSet in
                    store.send(.onDeleteAttendees(indexSet))
                })
                
                Button("New Attendee") {
                    store.send(.addAttendeeButtonTapped)
                }
            } header: {
                Text("Attendees")
            }
        }
        .bind($store.focus, to: $focus)
    }
}

struct ThemePicker: View {
    @Binding var selection: Theme
    
    var body: some View {
        Picker("Theme", selection: $selection) {
            ForEach(Theme.allCases) { theme in
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.mainColor)
                    Label(theme.name, systemImage: "paintpalette")
                        .padding(4)
                }
                .foregroundColor(theme.accentColor)
                .fixedSize(horizontal: false, vertical: true)
                .tag(theme)
            }
        }
    }
}

extension Duration {
    fileprivate var minutes: Double {
        get { Double(components.seconds / 60) }
        set { self = .seconds(newValue * 60) }
    }
}


#Preview {
    SyncUpFormView(
        store: Store(
            initialState: SyncUpForm.State(syncUp: .mock),
            reducer: {
                SyncUpForm()
            }
        )
    )
}
