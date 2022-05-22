//
//  MainMenu.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 20/05/2022.
//

import SwiftUI

struct MainMenu : View {
    @Environment(\.appState)
    var appState: Binding<AppState>
    
    var body: some View {
        HStack {
            LazyVStack {
                Button(action: {
                    appState.wrappedValue = .game
                }) {
                    Label("New game", systemImage: "plus.circle.fill")
                }
            }
            MainMenuMatchList()
        }
        .padding()
        .buttonStyle(MainMenuButtonStyle())
    }
}
