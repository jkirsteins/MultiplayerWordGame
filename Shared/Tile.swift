//
//  Tile.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 04/05/2022.
//

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

