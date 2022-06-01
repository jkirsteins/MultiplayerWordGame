//
//  MatchLoader.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 22/05/2022.
//

import SwiftUI
import GameKit

/// Loads and sets in environment a list of known matches
/// but the matches are not guaranteed to have associated data.
struct MatchLoaderWithoutDataGuarantees<Content: View> : View {
    let content: ()->Content
    
    @State var onlineMatches: [Match]? = nil
    
    @Environment(\.fatalErrorBinding)
    var fatalError: Binding<Error?>
    
    @AppStorage(AppStorageKey.localMatches.rawValue)
    var localMatches = Set<LocalMatch>()
    
    let localPlayer = GKLocalPlayer.local
    
    var body: some View {
        if let onlineMatches = onlineMatches {
            content()
                .environment(\.currentMatches, onlineMatches + localMatches.map { .local($0) } )
        } else if localPlayer.isAuthenticated {
            PleaseWait("Loading online games...")
                .frame(minHeight: 100)
                .task {
                    do {
                        self.onlineMatches = (try await GKTurnBasedMatch.loadMatches()).map {
                            .online($0, nil)
                        }
                    } catch {
                        self.fatalError.wrappedValue = error
                    }
                }
        } else {
            content()
                .environment(\.currentMatches, localMatches.map { .local($0) } )
        }
    }
}
