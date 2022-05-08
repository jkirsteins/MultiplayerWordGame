import SwiftUI

let SHADOW_REG_HEIGHT = 4.0
let SHADOW_LOW_HEIGHT = 2.0

struct LetterTile_Static: View {
    let letter: String
    let color: Color
    let textColor: Color 
    let lowered: Bool
    let lowerTop: Bool
    
    init(
        _ letter: String, 
        color: Color = LetterTileBase.LIGHT_COLOR,
        textColor: Color = .black, 
        lowered: Bool = false,
        lowerTop: Bool = true) {
        self.letter = letter 
        self.color = color
        self.textColor = textColor
        self.lowered = lowered
            self.lowerTop = lowerTop
    }
    
    var topColor: Color {
        color
    }
    
    var bottomColor: Color {
        color.darker
    }
    
    var firstLetter: String? {
        lowered ? letter : nil
    }
    
    var body: some View {
        ZStack {
            LetterTileBase(
                letter: nil, 
                color: bottomColor, 
                lowered: SHADOW_REG_HEIGHT,
                lowerTop: true)
            
            LetterTileBase(
                letter: letter, 
                color: topColor, 
                lowered: lowered ? (SHADOW_REG_HEIGHT - SHADOW_LOW_HEIGHT) : 0,
                lowerTop: lowerTop)
        }
    }
}

struct LetterTileBase: View {
    static let LIGHT_COLOR = Color(hex: 0xf6d2aa)
    static let DARK_COLOR = Color(hex: 0xf6d2aa).darker
    
    let letter: String?
    let color: Color
    let lowered: CGFloat?
    let lowerTop: Bool
    
    init(letter: String?, color: Color, lowered: CGFloat?, lowerTop: Bool) {
        self.letter = letter 
        self.color = color 
        self.lowered = lowered
        self.lowerTop = lowerTop
    }
    
    var cornerRadius: CGFloat {
        5
    }
    
    let regularTextColor = Color(hex: 0x1f1b14)
    let regularColor = Color(hex: 0xf6d2aa)
    
    var body: some View {
        VStack {
            if lowerTop, let lowered = lowered {
                Spacer().frame(maxHeight: lowered)
            }
            
            if let letter = letter {
            RoundedRectangle(
                cornerRadius: cornerRadius, 
                style: .continuous)
                .fill(color)
                .overlay(
                    Text(letter)
                        .fontWeight(.bold)
                        .font(.system(size: 500))
                        .minimumScaleFactor(0.0001)
                )
            } else {
                RoundedRectangle(
                    cornerRadius: cornerRadius, 
                    style: .continuous)
                    .fill(color)
            }
            
            if let lowered = lowered {
                Spacer().frame(
                    maxHeight: SHADOW_REG_HEIGHT - lowered)
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
}

struct LetterTileBase_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            TileInHand(letter: .init("A", points: 5))
            LetterTile_Static("A")
        }
        
        HStack {
            LetterTile_Static("W", lowered: true)
            LetterTile_Static("W", lowered: false)
            LetterTile_Static("W", lowered: true, lowerTop: false)
        }
        .frame(maxWidth: 250, maxHeight: 250)
    }
}
