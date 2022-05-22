//
//  MainMenuMatchList.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 22/05/2022.
//

import SwiftUI
import GameKit

struct MainMenuMatchList: View {
    @Environment(\.currentMatches)
    var matches: [GKTurnBasedMatch]
    
    var body: some View {
        
        if matches.count > 0 {
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 16) {
                    ForEach(matches, id: \.matchID) {
                        match in
                        
                        MatchThumbnail()
                            .environment(\.currentMatch, match)
                    }
                }
                .padding()
                .border(.primary)
            }
        }
        
        if matches.count == 0 {
            VStack {
                Spacer()
                Text("No matches have been created")
                Spacer()
            }
            .padding()
            .border(.primary)
        }
    }
}
