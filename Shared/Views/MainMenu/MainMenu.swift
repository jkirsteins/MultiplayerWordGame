//
//  MainMenu.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 20/05/2022.
//

import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}

struct MainMenu : View {
    @Environment(\.appState)
    var appState: Binding<AppState>
    
    @EnvironmentObject
    var globalConfig: GlobalConfiguration
    
    var body: some View {
        HStack {
            LazyVStack {
                Button(action: {
                    appState.wrappedValue = .creatingOnlineMatch
                }) {
                    Label("New online game", systemImage: "plus.circle.fill")
                }
                .if(!globalConfig.onlineAvailable) {
                    $0.help("Online games are available with GameKit.")
                }
                .disabled(!globalConfig.onlineAvailable)
                
                Button(action: {
                    appState.wrappedValue = .creatingLocalMatch
                }) {
                    Label("New local game", systemImage: "plus.circle.fill")
                }
            }
            MainMenuMatchList()
        }
        .padding()
        .buttonStyle(MainMenuButtonStyle())
    }
}
