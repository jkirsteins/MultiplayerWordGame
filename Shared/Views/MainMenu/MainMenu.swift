//
//  MainMenu.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 20/05/2022.
//

import SwiftUI

struct GameThumbnail: View {
    let color: Color
    
    @Environment(\.appState)
    var appState: Binding<AppState>
    
    var body: some View {
        Rectangle().fill(color)
            .aspectRatio(1, contentMode: .fit)
            .frame(minWidth: 150, minHeight: 150)
            .frame(maxWidth: 200)
            .onTapGesture {
                appState.wrappedValue = .game
            }
    }
}

struct MainMenu : View {
    @Environment(\.appState)
    var appState: Binding<AppState>
    
    var body: some View {
        HStack {
            LazyVStack {
                Button("New game") {
                    appState.wrappedValue = .game
                }
                .buttonStyle(.plain)
            }
            ScrollView {
                LazyVStack(spacing: 16) {
                    GameThumbnail(color: .red)
                    GameThumbnail(color: .green)
                    GameThumbnail(color: .blue)
                    GameThumbnail(color: .yellow)
                    GameThumbnail(color: .purple)
                }
            }
        }.padding()
    }
}
