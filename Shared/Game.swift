import SwiftUI

struct Game: View {
    @StateObject var state = GameState(15, 15)
    
    var cols: Int { state.cols } 
    var rows: Int { state.rows }
    let spacing = CGFloat(2)
    
    @State var scale: CGFloat = 1.0
    @State var isScaling = false
    @State var referenceScale: CGFloat = 1.0
    
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
            VStack {
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
            }
            .environment(\.gridConfig, GridConfig(
                spacing: spacing, 
                idealTileSize: pr.size.div(CGFloat(cols)).dec(spacing).minsq(), 
                rows: rows, 
                cols: cols))
            .environmentObject(state)
            .environment(\.player, 
                          Player(index: 0, color: .green))
            .debugBorder(.purple)
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
