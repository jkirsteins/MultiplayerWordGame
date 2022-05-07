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
                .placing(player.index, _, _, _):
            return true 
        default:
            return false
        }
    }
    
    var cursor: Cursor? {
        guard 
            case .placing(player.index, let cp, let dir, _) = state.state 
        else {
            return nil
        }
        
        return Cursor(point: cp, direction: dir)
    }
    
    var body: some View {
        ZStack {
            Button(
                action: {
                    self.state.startPlacing(for: player.index, at: self.point)
                }, label: {
                    Rectangle()
                        .fill(color)
                        .frame(maxWidth: 50, maxHeight: 50)
                        .aspectRatio(1, contentMode: .fit)
                        .border(.white, width: 1)
                })
                .disabled(!canPlaceWord)
            
            if let cp = self.cursor, cp.point == point {
                
                Rectangle()
                    .fill(.white)
                    .opacity(0.5)
                    .frame(maxWidth: 50, maxHeight: 50)
                    .aspectRatio(1, contentMode: .fit)
                    .border(.white, width: 1)
                
                Group {
                    if cp.direction == .right {
                        Image(systemName: "arrow.right.square.fill")
                            .blinking()
                        
                    } else {
                        Image(systemName: "arrow.down.square.fill")
                            .blinking()
                        
                    }
                }
                .foregroundColor(.white)
            } else {
                /* only show overlay if we're not blinking 
                 the cursor */
                if let overlay = overlay {
                    overlay
                }
            }
        }
    }
}

struct Tile3XW: View {
    let point: Point 
    
    var body: some View {
        Tile(color: .red.darker, point: point)
    }
}

struct Tile2XW<Overlay: View>: View {
    let point: Point 
    let overlay: Overlay
    
    init(point: Point) where Overlay == EmptyView {
        self.point = point
        self.overlay = EmptyView()
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
            point: point)
    }
}

struct Tile3XL: View {
    let point: Point
    
    var body: some View {
        Tile(color: .blue.darker, point: point)
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

