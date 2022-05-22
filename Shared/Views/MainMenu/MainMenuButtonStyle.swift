//
//  MainMenuButtonStyle.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 22/05/2022.
//

import SwiftUI

struct MainMenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

struct MainMenuButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: { print("Pressed") }) {
            Label("Press Me", systemImage: "star")
        }
        .buttonStyle(MainMenuButtonStyle())
    }
}
