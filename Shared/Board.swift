//
//  Board.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 04/05/2022.
//

import SwiftUI

struct Board : View {
    let model: BoardModel
    
    @EnvironmentObject
    var gameState: GameState
    
    @Environment(\.player)
    var player: Player
    
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
            
            innerBody
                .padding(24)
        }
    }
    
    var gridItems: [GridItem] {
        .init(repeating: GridItem(
            .flexible(minimum: 30, maximum: 60),
            spacing: 2, 
            alignment: .topLeading), count: model.cols)
    }
    
    @ViewBuilder
    var innerBody: some View {
        LazyVGrid(
            columns: gridItems, 
            //alignment: .top, 
            spacing: 2) {
                self.tiles
            }
    }
    
    @ViewBuilder
    var tiles: some View {
        ForEach(0..<model.rows) { rowIx in
            ForEach(0..<model.cols) { colIx in
                
                let point = Point(x: colIx, y: rowIx)
                
                ZStack {
                    tile(at: point).overlay(
                        overlayTile(at: point)
                    )
                }
            }
        }
    }
    
    func overlayTile(at point: Point) -> AnyView
    {
        guard case .placing(player.index, let data) = gameState.state else {
            return AnyView(EmptyView())
        }
        
        let pointIx = point.y * model.cols + point.x
        if case .some(.letter(let xxx)) = model.board.optGet(pointIx) {
            return AnyView(EmptyView())
        }
        
        func skip(from o: Point, horizontally count: Int) -> Int {
            guard count > 0 else {
                return 0
            }
            
            var result = 0
            for ix in 0..<count {
                let realIx = o.y * self.model.cols + o.x + ix
                if case .some(.letter(_)) = model.board.optGet(realIx) {
                    result += 1
                } else {
                    print("Nothing", model.board.optGet(realIx))
                }
            }
            return result
        }
        
        func skip(from o: Point, vertically count: Int) -> Int {
            guard count > 0 else {
                return 0
            }
            
            var result = 0
            for ix in 0..<count {
                let realIx = (o.y + ix) * self.model.cols + o.x 
                if case .some(.letter(_)) = model.board.optGet(realIx) {
                    result += 1
                } else {
                    print("Nothing", model.board.optGet(realIx))
                }
            }
            return result
        }
        
        let letterIndex: Int?
        switch(data.direction, data.origin.x, data.origin.y) {
        case (.right, _, point.y):
            letterIndex = point.x - data.origin.x - skip(from: data.origin, horizontally: point.x - data.origin.x)
        case (.down, point.x, _):
            letterIndex = point.y - data.origin.y - skip(from: data.origin, vertically: point.y - data.origin.y)
        default:
            letterIndex = nil
        }
        
        if point.x == 3 && point.y == 1 {
            let skip = skip(from: data.origin, horizontally: point.x - data.origin.x)
            print("Yo", letterIndex, skip)
        }
        
        if let ix = letterIndex {
            if let l = data.placed.optGet(ix) {
                return AnyView(LetterTile_Static(
                    l.letter.value,
                    color: player.color,
                    lowered: true,
                    lowerTop: false))
            }
            
            if ix == data.placed.count && data.placed.count < 7 {
                let cursor = ZStack {
                                Rectangle()
                                    .fill(.black)
                                    .opacity(0.5)
                                    .frame(maxWidth: 50, maxHeight: 50)
                                    .aspectRatio(1, contentMode: .fit)
                                    .border(.white, width: 1)
                                
                                Group {
                                    if data.direction == .right {
                                        Image(systemName: "arrow.right.square.fill")
                                            .blinking()
                                        
                                    } else {
                                        Image(systemName: "arrow.down.square.fill")
                                            .blinking()
                                        
                                    }
                                }
                                .foregroundColor(.white)
                }
                return AnyView(cursor)
            }
//            return AnyView(TileInHand(letter: l.letter))
        }
        
        return AnyView(EmptyView())
    }
    
    @ViewBuilder 
    func tile(at point: Point) -> some View {
        let ix = point.y * self.model.cols + point.x
        let tileModel: TileModel = self.model.board[ix] 
        switch(tileModel) {
        case .letter(let l):
            LetterTile_Static(
                l.value, 
                lowered: false, 
                lowerTop: true)
        default:
            underlyingTile(at: point)
        } 
    }
    
    @ViewBuilder 
    func underlyingTile(at point: Point) -> some View {
        switch(point.x, point.y) {
        case (7, 7):
            TileStart(point: point)
        case (5, 1), (9, 1),
            (1, 5), (5, 5),
            (13, 5), (9, 5),
            (1, 9), (5, 9),
            (13, 9), (9, 9),
            (5, 13), (9, 13):
            Tile3XL(point: point)
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
            Tile2XL(point: point)
        case
            (0, 0), (7, 0), (14, 0),
            (0, 7), (14, 7),
            (0, 14), (7, 14), (14, 14):
            Tile3XW(point: point)
        case (let a, let b) where a == b && a*b > 0:
            Tile2XW(point: point)
        case (let a, let b) where a == 14 - b && a*b > 0:
            Tile2XW(point: point)
        default:
            TileRegular(point: point)
        }
    }
}

