//
//  Board.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 04/05/2022.
//

import SwiftUI

enum TileLevel {
    case base
    case overlay
}

class BoardView {
    let model: BoardModel
    
    init(model: BoardModel) {
        self.model = model
    }
    
    func tile(at point: Point, state: GameState.GameStateOption, player: PlayerIndex, level: TileLevel) -> TileModel? {
        return self.tileAt(x: point.x, y: point.y, state: state, player: player, level: level)
    }
    
    func isLetter(x: Int, y: Int) -> Bool {
        guard case .letter(_) = self.model.tileAt(x: x, y: y) else {
            return false
        }
        
        return true
    }
    
    /// Determine an index into the currently-placed-word
    func letterIndex(x: Int, y: Int, placing: PlacingData) -> Int? {
        
        // If the underlying is a non-placing letter tile, then there can be
        // no indexing of placed tiles
        guard !self.isLetter(x: x, y: y) else {
            return nil
        }
        
        let letterIndex: Int?
        switch(placing.direction, placing.origin.x, placing.origin.y) {
        case (.right, _, y):
            letterIndex = x - placing.origin.x - skip(from: placing.origin, horizontally: x - placing.origin.x)
        case (.down, x, _):
            letterIndex = y - placing.origin.y - skip(from: placing.origin, vertically: y - placing.origin.y)
        default:
            letterIndex = nil
        }
        return letterIndex
    }
    
    func tileAt(x: Int, y: Int, state: GameState.GameStateOption, player: PlayerIndex, level: TileLevel) -> TileModel? {
        guard let pointIx = model.index(x: x, y: y) else {
            return nil
        }
        
        guard case .overlay = level else {
            return model.tileAt(x: x, y: y)
        }
        
        /* If not placing a tile, there can be no overlay */
        guard case .placing(player, let data) = state else {
            return nil
        }
        
        /* An underlying letter means there can be no further overlays */
        if case .some(.letter(_)) = model.board.optGet(pointIx) {
            return nil
        }
        
        /* If we have an index, it means we are in the row/col of the currently placed word.
         We have options:
         - if index is < placedWord.count, we should return a letter
         - if index == placedWord.count, we are at the end of the word. If we can
         still place letters, we can return a cursor.
         - if index is greater, we can return the underlying.
         to that letter. */
        if let letterIndex = letterIndex(x: x, y: y, placing: data) {
            if let idLetter = data.placed.optGet(letterIndex) {
                return .letter(idLetter.letter)
            }
            
            if letterIndex == data.placed.count && data.placed.count < 7 {
                return .cursor(data.direction)
            }
        }
        
        return nil
    }
    
    func flattened(placed: PlacingData) -> BoardModel {
        var processedIx = -1
        var result: BoardModel = self.model
        var point = placed.origin
        
        while processedIx < placed.placed.count {
            defer {
                point = point.moved(placed.direction)
            }
            
            let currentIx = letterIndex(x: point.x, y: point.y, placing: placed)
            guard
                let currentIx = currentIx
            else {
                continue
            }
            
            print("!Cont", currentIx)
            processedIx = currentIx
            
            // currentIx can be too big if it points to e.g. cursor
            if currentIx < placed.placed.count {
                result = result.changed(
                    .letter(placed.placed[currentIx].letter),
                    x: point.x,
                    y: point.y)
            }
        }
        
        return result
    }
    
    private func skip(from o: Point, horizontally count: Int) -> Int {
        guard count > 0 else {
            return 0
        }
        
        var result = 0
        for ix in 0..<count {
            let realIx = o.y * self.model.cols + o.x + ix
            if case .some(.letter(_)) = model.board.optGet(realIx) {
                result += 1
            }
        }
        return result
    }
    
    private func skip(from o: Point, vertically count: Int) -> Int {
        guard count > 0 else {
            return 0
        }
        
        var result = 0
        for ix in 0..<count {
            let realIx = (o.y + ix) * self.model.cols + o.x
            if case .some(.letter(_)) = model.board.optGet(realIx) {
                result += 1
            }
        }
        return result
    }
}

struct Board : View {
    let boardView: BoardView
    
    init(model: BoardModel) {
        self.boardView = BoardView(model: model)
    }
    
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
            alignment: .topLeading), count: boardView.model.cols)
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
    
    struct _IdentifiableIx: Identifiable {
        let prefix: String
        let value: Int
        
        var id: String {
            "\(prefix)-\(value)"
        }
    }
    
    @ViewBuilder
    var tiles: some View {
        ForEach((0..<boardView.model.rows).map({_IdentifiableIx(prefix: "row", value: $0)}))
        {
            rowIx in
            ForEach((0..<boardView.model.cols).map({_IdentifiableIx(prefix: "row-\(rowIx.value)-col", value: $0)})) { colIx in
                
                tile(at: Point(x: colIx.value, y: rowIx.value)).overlay(
                    overlayTile(at: Point(x: colIx.value, y: rowIx.value))
                )
            }
        }
    }
    
    func overlayTile(at point: Point) -> AnyView
    {
        guard let tile = boardView.tile(
            at: point,
            state: gameState.state,
            player: player.index,
            level: .overlay) else {
            return AnyView(EmptyView())
        }
        
        if case .letter(let letter) = tile {
            return AnyView(LetterTile_Static(
                letter.value,
                color: player.color,
                lowered: true,
                lowerTop: false))
        }
        
        if case .cursor(let dir) = tile {
            let cursor = ZStack {
                Rectangle()
                    .fill(.black)
                    .opacity(0.5)
                    .frame(maxWidth: 50, maxHeight: 50)
                    .aspectRatio(1, contentMode: .fit)
                    .border(.white, width: 1)
                
                Group {
                    if dir == .right {
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
        
        return AnyView(EmptyView())
    }
    
    func tile(at point: Point) -> AnyView {
        guard let tile = boardView.tile(
            at: point,
            state: gameState.state,
            player: player.index,
            level: .base) else {
            return AnyView(EmptyView())
        }
        
        switch(tile) {
        case .letter(let l):
            return AnyView(LetterTile_Static(
                l.value,
                lowered: false,
                lowerTop: true))
        default:
            return AnyView(underlyingTile(at: point))
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

