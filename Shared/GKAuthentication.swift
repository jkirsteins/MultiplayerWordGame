//
//  GKAuthentication.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 04/05/2022.
//

import SwiftUI
import GameKit

enum GKAuthState {
    case signingIn
    case signedIn
    case signedOut
    case failed(error: Error)
}

struct GKAuthentication<Content: View>: View {
    
    @State var state: GKAuthState = .signingIn
    
    let localPlayer = GKLocalPlayer.local
    
    let content: Content
    
    init(@ViewBuilder _ content: ()->Content) {
        self.content = content()
    }
    
    func authenticateUser() {
        localPlayer.authenticateHandler = { vc, error in
            if let error = error {
                self.state = .failed(error: error)
                return
            }
            
            GKAccessPoint.shared.isActive = localPlayer.isAuthenticated
            
            switch(localPlayer.isAuthenticated) {
            case true:
                self.state = .signedIn
            case false:
                self.state = .signedOut
            }
        }
    }
    
    var body: some View {
        Group {
            switch(state) {
            case .signedIn:
                content
            case .signingIn:
                Text("Signing in...")
            case .signedOut:
                VStack {
                    Text("Not logged in").font(.largeTitle)
                    Text("This game requires GameKit. Please ensure you are logged in and then restart the game.")
                }
            case .failed(let error):
                VStack {
                    Text("Login failed").font(.largeTitle)
                    if let locdesc = error.localizedDescription {
                        Text(locdesc).foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 300, minHeight: 300)
        .onAppear {
            authenticateUser()
        }
    }
}
