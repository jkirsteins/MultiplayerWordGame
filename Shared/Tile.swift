//
//  Tile.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 04/05/2022.
//

import SwiftUI

struct Cursor {
    let point: Point 
    let direction: WordDirection
}

struct Tile<Overlay: View> : View {
    let color: Color
    let point: Point
    let overlay: Overlay?
    
    @EnvironmentObject
    var state: GameState
    
    @Environment(\.player)
    var player: Player
    
    init(color: Color, point: Point) where Overlay == EmptyView {
        self.color = color 
        self.point = point 
        self.overlay = nil
    }
    
    init(color: Color, point: Point, @ViewBuilder _ overlay: ()->Overlay) {
        self.color = color 
        self.point = point 
        self.overlay = overlay()
    }
    
    var canPlaceWord: Bool {
        switch(state.state) {
        case 
                .idle(player.index), 
                .placing(player.index, _):
            return true 
        default:
            return false
        }
    }
    
    var cursor: Cursor? {
        guard 
            case .placing(player.index, let data) = state.state 
        else {
            return nil
        }
        
        return Cursor(point: data.origin, direction: data.direction)
    }
    
    var body: some View {
        ZStack {
            Button(
                action: {
                    self.state.startPlacing(for: player.index, at: self.point)
                }, label: {
                    Rectangle()
                        .fill(color)
                        .aspectRatio(1, contentMode: .fit)
                        .border(.white, width: 1)
                })
                .disabled(!canPlaceWord)
                .buttonStyle(.plain)
            
//            if let cp = self.cursor, cp.point == point {
//                Rectangle()
//                    .fill(.white)
//                    .opacity(0.5)
//                    .frame(maxWidth: 50, maxHeight: 50)
//                    .aspectRatio(1, contentMode: .fit)
//                    .border(.white, width: 1)
//                
//                Group {
//                    if cp.direction == .right {
//                        Image(systemName: "arrow.right.square.fill")
//                            .blinking()
//                        
//                    } else {
//                        Image(systemName: "arrow.down.square.fill")
//                            .blinking()
//                        
//                    }
//                }
//                .foregroundColor(.white)
//            } else {
                /* only show overlay if we're not blinking 
                 the cursor */
                if let overlay = overlay {
                    overlay
                }
//            }
        }
    }
}

struct TileTextOverlay: View {
    let text: String 
    
    let padding = CGFloat(4)
    
    var body: some View {
        GeometryReader { gr in 
            Text(text)
                .fontWeight(.bold)
                .frame(
                    idealWidth: gr.size.width - padding*2,
                    maxWidth: .infinity,
                    idealHeight: gr.size.height - padding*2,
                    maxHeight: .infinity)
                .font(.system(size: 5000))
                .minimumScaleFactor(0.001)
                .foregroundColor(.white)
                .padding(padding)
        }
    }
}

struct Tile3XW: View {
    let point: Point 
    
    var body: some View {
        Tile(color: .red.darker, point: point) {
            TileTextOverlay(text: "TW")
        }
    }
}

struct Tile2XW<Overlay: View>: View {
    let point: Point 
    let overlay: Overlay
    
    init(point: Point) where Overlay == TileTextOverlay {
        self.point = point
        self.overlay = TileTextOverlay(text: "DW")
    }
    
    init(point: Point, @ViewBuilder _ overlay: ()->Overlay) {
        self.point = point
        self.overlay = overlay()
    }
    
    var body: some View {
        Tile(
            color: .red.lighter.lighter.lighter.lighter.lighter,
            point: point,
            { overlay })
    }
}

struct TileRegular: View {
    let point: Point
    
    var body: some View {
        Tile(color: .teal, point: point)
    }
}

struct Tile2XL: View {
    let point: Point 
    
    var body: some View {
        Tile(
            color: .blue.lighter.lighter,
            point: point) {
                TileTextOverlay(text: "DL")
                // TODO: fix text sizing properly for when DL/TL 
                // are diff size from DW/TW due to W being wide
//                    .padding(2)
            }
    }
}

struct Tile3XL: View {
    let point: Point
    
    var body: some View {
        Tile(color: .blue.darker, point: point) {
            TileTextOverlay(text: "TL")
            // TODO: fix text sizing properly for when DL/TL 
            // are diff size from DW/TW due to W being wide
//                .padding(2)
        }
    }
}

struct TileStart: View {
    let point: Point
    
    var body: some View {
        Tile2XW(point: point) {
            Image(systemName: "star.circle.fill")
                .foregroundColor(.red.darker)
        }
    }
}

