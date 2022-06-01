import SwiftUI
import GameKit

extension GKTurnBasedParticipant : Identifiable {
    public var id: String {
        self.player?.gamePlayerID ?? "unknown"
    }
}

//extension GKTurnBasedParticipant {
//
//}

struct GamePlayerListPlayer: View {
    let participant: GKTurnBasedParticipant
    
    var playerDescription: String {
        var result = isLocal ? "You" : (participant.player?.gamePlayerID ?? "<pending>")
        if isCurrent {
            result = "==> \(result)"
        }
        return result
    }
    
    @Environment(\.currentMatch)
    var match: Match
    
    var isCurrent: Bool {
        false
        //        match.currentParticipant == participant
    }
    
    var isLocal: Bool {
        GKLocalPlayer.local.gamePlayerID == participant.player?.gamePlayerID
    }
    
    var body: some View {
        Text(playerDescription)
            .foregroundColor(isLocal ? .green : .primary)
    }
}

struct GamePlayerList: View {
    @Environment(\.currentMatch)
    var match: Match
    
    var body: some View {
        VStack {
            Text("Players").font(.title)
            Divider()
            //            ForEach(match.participants) {
            //                part in
            //
            //                GamePlayerListPlayer(participant: part)
            //            }
        }
        .padding()
        .border(.primary)
    }
}

struct FullMatchView: View {
    var body: some View {
        Text("full match")
    }
}

/// Requires a `currentMatch` in environment,
/// and will load its full data before invoking the child views.
struct MatchDataLoader<Content: View>: View {
    
    @ViewBuilder var content: ()->Content
    
    enum _Error: Error {
        case noDataFound
    }
    
    /// Outer match is set by the environment which might not know
    /// how to properly initialize it. We take it as a starting point, but we don't
    /// propogate it/use it further (see `actualMatch`)
    @Environment(\.currentMatch)
    var outerMatch: Match
    
    @Environment(\.fatalErrorBinding)
    var fatalError: Binding<Error?>
    
    @State var actualMatch: Match? = nil
    
    var body: some View {
        switch(actualMatch, outerMatch) {
        case (_, .online(_, let md)) where md != nil:
            // Match didn't need loading so no changes to environment
            content()
        case (.online(_, let md), _) where md != nil:
            // Match loaded, so we need to prioritize over outerMatch
            content()
                .environment(\.currentMatch, actualMatch!)
        case (nil, .online(let partial, let md)) where md == nil:
            PleaseWait("Loading match \(outerMatch.id)...")
                .task {
                    do {
                        guard
                            let data = try await partial.loadMatchData()
                        else {
                            fatalError.wrappedValue = _Error.noDataFound
                            return
                        }
                        
                        let matchData = try MatchData(data)
                        actualMatch = .online(partial, matchData)
                    } catch {
                        fatalError.wrappedValue = error
                    }
                }
        default:
            Text("Unexpected state").task {
                print("Match", String(describing: actualMatch))
            }
        }
    }
}

struct Game: View {
    @Environment(\.currentMatch)
    var match: Match
    
    var body: some View {
        switch(match) {
        case .none:
            fatalError()
        case .local(_):
            ActiveMatch()
                .environmentObject(TurnManagerWrapper(LocalTurnManager()))
        case .online(_, _):
            MatchDataLoader {
                ActiveMatch()
                    .environmentObject(TurnManagerWrapper(GameKitTurnManager()))
            }
        }
    }
}

struct ActiveMatch: View {
    @StateObject var state = GameState(15, 15)
    
    var cols: Int { state.cols }
    var rows: Int { state.rows }
    let spacing = CGFloat(2)
    
    @State var scale: CGFloat = 1.0
    @State var isScaling = false
    @State var referenceScale: CGFloat = 1.0
    
    @EnvironmentObject
    var turnManager: TurnManagerWrapper
    
    @Environment(\.currentMatch)
    var match: Match
    
    @Environment(\.appState)
    var appState: Binding<AppState>
    
    var sce: CGFloat {
        isScaling ? scale * referenceScale : referenceScale
    }
    
    @State var boardSize: CGSize? = nil
    @State var initialSize: CGSize? = nil
    
    var scaledFrame: CGSize {
        (boardSize ?? .zero).mul(sce)
    }
    
    var body: some View {
        GeometryReader { pr in
            HStack {
                VStack {
                    if turnManager.isLocal {
                        Text("Hot Seat").font(.title)
                    } else {
                        Text("Online").font(.title)
                    }
                    Divider()
                    GamePlayerList()
                }
                .padding()
                
                Divider()
                VStack {
                    HStack {
                        Spacer()
                        Button("Back to menu") {
                            appState.wrappedValue = .menu
                        }
                    }
                    Text("Match: \(match.id)")
                    ScrollView([.horizontal, .vertical], showsIndicators: false) {
                        ZStack {
                            
                            // This sets the content size
                            // of the scrollview.
                            //
                            // It should be otherwise
                            // invisible and out of the way.
                            Rectangle()
                                .opacity(0.0)
                                .frame(
                                    minWidth:scaledFrame.width,
                                    minHeight: scaledFrame.height)
                            
                            Board(model: state.board)
                                .scaleEffect(sce)
                                .background(GeometryReader {
                                    bgp in
                                    
                                    Color.clear.onAppear {
                                        self.boardSize = bgp.size
                                        if initialSize == nil {
                                            initialSize = bgp.size
                                        }
                                    }.onChange(of: bgp.size) {
                                        self.boardSize = $0
                                        if initialSize == nil {
                                            initialSize = $0
                                        }
                                    }
                                })
                            /* Keep the frame from resizing
                             as the contentSize of the scrollview
                             changes (i.e. keep at initial size)
                             */
                                .frame(
                                    maxWidth:
                                        self.initialSize?.width,
                                    maxHeight:
                                        self.initialSize?.height
                                )
                        }
                        
                        //                    Rows()
                        //                        .scaleEffect(sce)
                        //                        .padding(.horizontal,
                        //                                 (pr.size.width * sce - pr.size.width) / 2.0)
                        //                        .padding(.vertical,
                        //                                 (pr.size.height * sce - pr.size.height) / 2.0)
                        //                        .border(.black, width: 2)
                    }.background(Color(hex: 0xEFEFEF))
                    
                    Text(verbatim: "State: \(state.state.debugDescription)")
                    Text(verbatim: "Remaining: \(state.dispenser.remaining.count)")
                    Text(verbatim: "\(boardSize?.roundedStr ?? "-") -> \(scaledFrame.roundedStr) -> \(initialSize?.roundedStr ?? "-")")
                    Text(verbatim: "Scaling \(sce)")
                    Hand()
                        .frame(maxHeight: 100)
                }
                .environment(\.gridConfig, GridConfig(
                    spacing: spacing,
                    idealTileSize: pr.size.div(CGFloat(cols)).dec(spacing).minsq(),
                    rows: rows,
                    cols: cols))
                .environmentObject(state)
                .environment(\.player, .local(PlayerData(index: 0, color: .green)))
                .debugBorder(.purple)
            }
        }
        .simultaneousGesture(MagnificationGesture()
            .onChanged({ (scale) in
                self.isScaling = true
                self.scale = scale
            }).onEnded { scale in
                self.isScaling = false
                self.referenceScale *= scale
                self.scale = 1.0
            })
        .environment(\.debug, false)
    }
}
