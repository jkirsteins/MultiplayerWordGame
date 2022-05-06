import SwiftUI

struct Game: View {
    @StateObject var state = GameState()
    
    var cols: Int { state.cols } 
    var rows: Int { state.rows }
    let spacing = CGFloat(2)
    
    @State var scale: CGFloat = 1.0
    @State var isScaling = false
    @State var isSwapping: [IdLetter]? = nil
    @State var referenceScale: CGFloat = 1.0
    
    var sce: CGFloat {
        isScaling ? scale * referenceScale : referenceScale
    }
    
    var body: some View {
        GeometryReader { pr in 
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                
                Rows()
                    .scaleEffect(sce)
                    .padding(.horizontal,
                             (pr.size.width * sce - pr.size.width) / 2.0)
                    .padding(.vertical,
                             (pr.size.height * sce - pr.size.height) / 2.0)
                    .border(.black, width: 2)
                
                Text(verbatim: "Remaining: \(state.dispenser.remaining.count)")
                
                if isSwapping != nil {
                    Text("Please select the letters you wish to swap.")
                }
                
                HStack {
                    ForEach(state.hands[0].letters.sorted()) {
                        l in 
                        
                        Button("\(l.letter.value)") {
                            if var isSwapping = isSwapping {
                                if let ix = isSwapping.firstIndex(of: l) {
                                    isSwapping.remove(at: ix)
                                } else {
                                    isSwapping.append(l)
                                }
                                self.isSwapping = isSwapping
                            } else {
                                print("Placing \(l.letter.value)")
                            }
                        }
                        .frame(
                            minWidth: 30,
                            minHeight: 30)
                        .border(isSwapping?.contains(l) == true ? .red : .gray)
                    }
                }
                
                HStack {
                    if let isSwapping = isSwapping {
                        VStack(spacing: 8) {
                            Button("Apply swap") {
                                self.state.swapLetters(isSwapping, for: self.state.hands[0])
                                self.isSwapping = nil
                            }.disabled(isSwapping.isEmpty)
                            
                            Button("Cancel swap") {
                                self.isSwapping = nil
                            }
                            
                            Button("Invert swap") {
                                self.isSwapping = self.state.hands[0].letters.filter({ letter in
                                    !isSwapping.contains(letter)
                                })
                            }
                        }
                    } else {
                        Button("Swap") {
                            self.isSwapping = self.state.hands[0].letters
                        }
                        
                        Button("Submit") {
                            
                        }
                    }
                }
                
            }
            .environment(\.gridConfig, GridConfig(
                spacing: spacing, 
                idealTileSize: pr.size.div(CGFloat(cols)).dec(spacing).minsq(), 
                rows: rows, 
                cols: cols))
            .environmentObject(state)
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
