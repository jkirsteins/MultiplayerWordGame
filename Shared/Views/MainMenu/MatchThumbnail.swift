//
//  MatchThumbnail.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 22/05/2022.
//

import SwiftUI
import GameKit

struct MatchThumbnail: View {
    @Environment(\.appState)
    var appState: Binding<AppState>
    
    @Environment(\.currentMatch)
    var match: GKTurnBasedMatch
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(.gray)
            Text(match.matchID)
        }
            .aspectRatio(1, contentMode: .fit)
            .frame(minWidth: 150, minHeight: 150)
            .frame(maxWidth: 200)
            .onTapGesture {
                appState.wrappedValue = .game(match: match)
            }
    }
}
