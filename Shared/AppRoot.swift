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
    case creatingMatch
    case game(match: Match)
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
        GKAuthentication_Internal {
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
        case .creatingMatch:
            GKTurnBasedMatchmakerView(
                                minPlayers: 2,
                                maxPlayers: 4,
                                inviteMessage: "Let us play together!"
                            ) {
                state = .menu
            } failed: { (error) in
                fatalError = error
            } started: { (match) in
                print("Match Started")
            }
        case .game(let match):
            Game()
                .environment(\.currentMatch, match)
        }
    }
}
