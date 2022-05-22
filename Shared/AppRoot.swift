//
//  AppRoot.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 04/05/2022.
//

import SwiftUI
import GameKit

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

extension EnvironmentValues {
    var currentMatches: [GKTurnBasedMatch] {
        get { self[CurrentMatchKey.self] }
        set { self[CurrentMatchKey.self] = newValue }
    }
}

private struct CurrentMatchKey: EnvironmentKey {
    static let defaultValue: [GKTurnBasedMatch] = []
}

extension EnvironmentValues {
    var fatalErrorBinding: Binding<Error?> {
        get { self[FatalErrorKey.self] }
        set { self[FatalErrorKey.self] = newValue }
    }
}

private struct FatalErrorKey: EnvironmentKey {
    static let defaultValue: Binding<Error?> = .constant(nil)
}

struct PleaseWait: View {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
            Text(message)
        }
    }
}

struct MatchLoader<Content: View> : View {
    let content: ()->Content
    
    @State var matches: [GKTurnBasedMatch]? = nil
    
    @Environment(\.fatalErrorBinding)
    var fatalError: Binding<Error?>
    
    var body: some View {
        if let matches = matches {
            content()
                .environment(\.currentMatches, matches)
        } else {
            PleaseWait("Loading games...")
                .frame(minHeight: 100)
                .task {
                    do {
                        self.matches = try await GKTurnBasedMatch.loadMatches()
                    } catch {
                        self.fatalError.wrappedValue = error
                    }
                }
        }
    }
}

struct AppRoot : View {
    @State var state = AppState.menu
    @State var fatalError: Error? = nil
    
    var body: some View {
        VStack {
            if let fatalError = fatalError {
                Text(fatalError.localizedDescription)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 5).fill(.red))
                    .foregroundColor(.white)
                Spacer()
                Text("An unexpected error has happened and we don't know how to recover :(")
                Spacer()
            } else {
                authenticatedInnerBody
            }
        }
        .padding()
        #if os(macOS)
        .frame(minWidth: 640, minHeight: 480)
        #endif
            .environment(\.appState, $state)
            .environment(\.fatalErrorBinding, $fatalError)
    }
    
    @ViewBuilder
    var authenticatedInnerBody: some View {
        GKAuthentication {
            MatchLoader {
                unauthenticatedInnerBody
            }
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
