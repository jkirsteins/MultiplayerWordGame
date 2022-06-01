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
    var match: Match
    
    var isLocal: Bool {
        if case .local(_) = match {
            return true
        }
        return false
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    if isLocal {
                        Text("Local")
                    } else {
                        Text("Remote")
                    }
                    Spacer()
                }
                .padding()
                .background(Rectangle().fill(.yellow))
                
                Spacer()
                Text(match.id)
                Spacer()
            }
        }
        .background(.gray)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .aspectRatio(1, contentMode: .fit)
        .frame(minWidth: 150, minHeight: 150)
        .frame(maxWidth: 200)
        .onTapGesture {
            appState.wrappedValue = .game(match: match)
        }
    }
}
