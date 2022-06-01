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
    case creatingMatch(local: Bool)
    case game(match: Match)
    
    static let creatingLocalMatch = AppState.creatingMatch(local: true)
    static let creatingOnlineMatch = AppState.creatingMatch(local: false)
}

enum AppStorageKey: String {
    case localMatches
}

extension Set: RawRepresentable where Element == LocalMatch {
    public init?(rawValue: String) {
        let decoder = JSONDecoder()
        guard let data = rawValue.data(using: .utf8) else {
            return nil
        }
        guard let decoded = try? decoder.decode(Set<Element>.self, from: data) else {
            return nil
        }
        
        self = decoded
    }
    
    public var rawValue: String {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(self)
        return String(data: encoded, encoding: .utf8)!
    }
    
    public typealias RawValue = String
}

struct AppRoot : View {
    @State var state = AppState.menu
    @State var fatalError: Error? = nil
    
    @AppStorage(AppStorageKey.localMatches.rawValue)
    var localMatches = Set<LocalMatch>()
    
    @StateObject
    var globalConfig = GlobalConfiguration()
    
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
        .environmentObject(globalConfig)
    }
    
    @ViewBuilder
    var authenticatedInnerBody: some View {
        GKAuthentication_Internal {
            MatchLoaderWithoutDataGuarantees {
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
        case .creatingMatch(local: true):
            PleaseWait("TODO: add customization options").task {
                let newLocalMatch = LocalMatch(data: MatchData())
                self.localMatches.insert(newLocalMatch)
                state = .game(match: .local(newLocalMatch))
            }
        case .creatingMatch(local: false):
            GKTurnBasedMatchmakerView(
                                minPlayers: 2,
                                maxPlayers: 4,
                                inviteMessage: "Let us play together!"
                            ) {
                state = .menu
            } failed: { (error) in
                fatalError = error
            } started: { (gkMatch) in
                state = .game(match: .online(gkMatch, nil))
            }
        case .game(let match):
            Game()
                .environment(\.currentMatch, match)
        }
    }
}
