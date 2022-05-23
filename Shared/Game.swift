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

struct PartialOnlineLoader: View {
    
    enum _Error: Error {
        case noDataFound
    }
    
    @Environment(\.currentMatch)
    var outerMatch: Match
    
    @Environment(\.fatalErrorBinding)
    var fatalError: Binding<Error?>
    
    @State var fullyLoaded: Match? = nil
    
    var body: some View {
        switch(outerMatch) {
        case .partialOnline(let partial):
            if let fullyLoaded = fullyLoaded {
                Text("Fully loaded :-)")
            } else {
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
                            fullyLoaded = .online(partial, matchData)
                        } catch {
                            fatalError.wrappedValue = error
                        }
                    }
            }
        default:
            Game()
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
        case .local(_), .online(_, _):
            Game()
        case .partialOnline(_):
            PartialOnlineLoader()
        }
    }
}

struct ActiveGame: View {
    @StateObject var state = GameState(15, 15)
    
    var cols: Int { state.cols }
    var rows: Int { state.rows }
    let spacing = CGFloat(2)
    
    @State var scale: CGFloat = 1.0
    @State var isScaling = false
    @State var referenceScale: CGFloat = 1.0
    
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
