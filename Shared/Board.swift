//
//  Board.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 04/05/2022.
//

import SwiftUI

struct Board : View {
    let model: BoardModel
    
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

