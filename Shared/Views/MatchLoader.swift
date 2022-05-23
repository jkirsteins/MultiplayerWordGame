//
//  MatchLoader.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 22/05/2022.
//

import SwiftUI
import GameKit

struct MatchLoader<Content: View> : View {
    let content: ()->Content
    
    @State var matches: [Match]? = nil
    
    @Environment(\.fatalErrorBinding)
    var fatalError: Binding<Error?>
    
    var body: some View {
        if let matches = matches {
            content()
                .environment(\.currentMatches, matches)
        } else {
            PleaseWait("Loading games...")
                .frame(minHeight: 100)
                .task {
                    do {
                        self.matches = (try await GKTurnBasedMatch.loadMatches()).map {
                            .partialOnline($0)
                        }
                    } catch {
                        self.fatalError.wrappedValue = error
                    }
                }
        }
    }
}
