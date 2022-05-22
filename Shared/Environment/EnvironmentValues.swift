//
//  EnvironmentValues.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 22/05/2022.
//

import SwiftUI
import GameKit

extension EnvironmentValues {
    var appState: Binding<AppState> {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
    
    var currentMatches: [GKTurnBasedMatch] {
        get { self[CurrentMatchesKey.self] }
        set { self[CurrentMatchesKey.self] = newValue }
    }
    
    var currentMatch: GKTurnBasedMatch {
        get { self[CurrentMatchKey.self] }
        set { self[CurrentMatchKey.self] = newValue }
    }
    
    var fatalErrorBinding: Binding<Error?> {
        get { self[FatalErrorKey.self] }
        set { self[FatalErrorKey.self] = newValue }
    }
}

fileprivate struct AppStateKey: EnvironmentKey {
    static let defaultValue: Binding<AppState> = .constant(.unknown)
}

fileprivate struct CurrentMatchesKey: EnvironmentKey {
    static let defaultValue: [GKTurnBasedMatch] = []
}

fileprivate struct CurrentMatchKey: EnvironmentKey {
    static let defaultValue: GKTurnBasedMatch = GKTurnBasedMatch()
}

fileprivate struct FatalErrorKey: EnvironmentKey {
    static let defaultValue: Binding<Error?> = .constant(nil)
}
