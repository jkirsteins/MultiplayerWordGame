import SwiftUI

struct Game: View {
    @StateObject var state = GameState()
    
    var cols: Int { state.cols } 
    var rows: Int { state.rows }
    let spacing = CGFloat(2)
    
    @State var scale: CGFloat = 1.0
    @State var isScaling = false
    @State var referenceScale: CGFloat = 1.0
    
    var sce: CGFloat {
        isScaling ? scale * referenceScale : referenceScale
    }
    
    var body: some View {
        GeometryReader { pr in 
            VStack {
                ScrollView([.horizontal, .vertical], showsIndicators: true) {
                    
                    Rows()
//                        .scaleEffect(sce)
//                        .padding(.horizontal,
//                                 (pr.size.width * sce - pr.size.width) / 2.0)
//                        .padding(.vertical,
//                                 (pr.size.height * sce - pr.size.height) / 2.0)
                        .border(.black, width: 2)
                }
                
                Text(verbatim: "Remaining: \(state.dispenser.remaining.count)")
                Hand()
            }
            .environment(\.gridConfig, GridConfig(
                spacing: spacing, 
                idealTileSize: pr.size.div(CGFloat(cols)).dec(spacing).minsq(), 
                rows: rows, 
                cols: cols))
            .environmentObject(state)
            .environment(\.player, Player(index: 0))
            .debugBorder(.purple)
        }
//        .simultaneousGesture(MagnificationGesture()
//                                .onChanged({ (scale) in
//            self.isScaling = true
//            self.scale = scale
//        }).onEnded { scale in
//            self.isScaling = false
//            self.referenceScale *= scale 
//            self.scale = 1.0
//        })
        .environment(\.debug, false)
    }
}
