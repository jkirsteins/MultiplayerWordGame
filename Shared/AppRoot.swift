//
//  AppRoot.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 04/05/2022.
//

import SwiftUI

struct AppRoot : View {
    var body: some View {
        GKAuthentication {
            ContentView()
        }
    }
}
