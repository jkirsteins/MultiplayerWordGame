import SwiftUI

struct Tile : View {
    let color: Color 
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(maxWidth: 50, maxHeight: 50)
            .aspectRatio(1, contentMode: .fit)
            .border(.white, width: 1)
    }
}

struct Tile3XW: View {
    var body: some View {
        Tile(color: .red.darker)
    }
}

struct Tile2XW: View {
    var body: some View {
        Tile(color: .red.lighter.lighter.lighter.lighter.lighter)
    }
}

struct TileRegular: View {
    var body: some View {
        Tile(color: .teal)
    }
}

struct Tile2XL: View {
    var body: some View {
        Tile(color: .blue.lighter.lighter)
    }
}

struct Tile3XL: View {
    var body: some View {
        Tile(color: .blue.darker)
    }
}

struct TileStart: View {
    var body: some View {
        ZStack {
            Tile2XW()
            Image(systemName: "star.circle.fill")
                .foregroundColor(.red.darker)
        }
    }
}

struct Board<Content: View> : View {
    let content: Content
    
    init(@ViewBuilder _ content: (()->Content)) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.teal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
            
            Rectangle()
                .fill(Color.clear)
                .border(Color.white, width: 4)
                .aspectRatio(1, contentMode: .fit)
                .padding(24 - 6)
            
            content
                .padding(24)
        }
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            Board {
                VStack(spacing: 2) {
                    ForEach(0..<15) { rowIx in
                        HStack(spacing: 2) {
                            ForEach(0..<15) { colIx in
                                
                                switch(colIx, rowIx) {
                                    case (7, 7):
                                    TileStart()
                                case (5, 1), (9, 1),
                                    (1, 5), (5, 5),
                                    (13, 5), (9, 5),
                                    (1, 9), (5, 9),
                                    (13, 9), (9, 9),
                                    (5, 13), (9, 13):
                                    Tile3XL()
                                    case (3, 0), (11, 0),
                                    (3, 14), (11, 14),
                                    (6, 2), (7, 3), (8, 2),
                                    (6, 12), (7, 11), (8, 12),
                                    (2, 6), (3, 7), (2, 8),
                                    (12, 6), (11, 7), (12, 8),
                                    (0, 3), (14, 3),
                                    (0, 11), (14, 11),
                                    
                                    (6, 6), (8, 8),
                                    (6, 8), (8, 6)
                                    :
                                    Tile2XL()
                                case 
                                    (0, 0), (7, 0), (14, 0),
                                    (0, 7), (14, 7),
                                    (0, 14), (7, 14), (14, 14):
                                    Tile3XW()
                                case (let a, let b) where a == b && a*b > 0:
                                    Tile2XW()
                                case (let a, let b) where a == 14 - b && a*b > 0:
                                    Tile2XW()
                                default: 
                                    TileRegular()
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }
}
