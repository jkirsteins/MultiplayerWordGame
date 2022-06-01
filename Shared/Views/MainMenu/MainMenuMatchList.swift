//
//  MainMenuMatchList.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 22/05/2022.
//

import SwiftUI
import GameKit

class GlobalConfiguration: ObservableObject
{
    @Published var onlineAvailable: Bool = false
}

struct ErrorMessage: View {
    let message: LocalizedStringKey
    
    init(_ message: LocalizedStringKey) {
        self.message = message
    }
    
    var body: some View {
        HStack {
            Spacer()
            Text(message)
                .foregroundColor(.white)
                .padding()
            Spacer()
        }
        .background(RoundedRectangle(cornerRadius: 5).fill(.red))
    }
}

struct MainMenuMatchList: View {
    @Environment(\.currentMatches)
    var matches: [Match]
    
    @EnvironmentObject
    var globalConfig: GlobalConfiguration
    
    var body: some View {
        
        if matches.count > 0 {
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 16) {
                    ForEach(matches) {
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
                if !globalConfig.onlineAvailable {
                    ErrorMessage("Online matches are unavailable")
                }
                Text("No matches have been created")
                Spacer()
            }
            .padding()
            .border(.primary)
        }
    }
}
