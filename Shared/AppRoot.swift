//
//  AppRoot.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 04/05/2022.
//

import SwiftUI

enum AppState {
    case unknown
    case menu
    case game
}

extension EnvironmentValues {
    var appState: Binding<AppState> {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}

private struct AppStateKey: EnvironmentKey {
    static let defaultValue: Binding<AppState> = .constant(.unknown)
}

struct AppRoot : View {
    @State var state = AppState.menu
    
    var body: some View {
        unauthenticatedInnerBody
            .environment(\.appState, $state)
    }
    
    @ViewBuilder
    var authenticatedInnerBody: some View {
        GKAuthentication {
            unauthenticatedInnerBody
        }
    }
    
    @ViewBuilder
    var unauthenticatedInnerBody: some View {
        switch(state) {
        case .unknown:
            Text("Error, unknown game state.")
        case .menu:
            MainMenu()
        case .game:
            Game()
        }
    }
}
