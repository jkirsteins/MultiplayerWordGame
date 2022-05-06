import SwiftUI

fileprivate let MAX_SIDE = CGFloat(25)

fileprivate struct TileInHandButtonStyle: ButtonStyle {
    
    var shadowHeight: CGFloat {
        //        config.idealTileSize.height / 17.50
        2.0
    }
    
    var cornerRadius: CGFloat {
        5
    }
    
    let regularTextColor = Color(hex: 0x1f1b14)
    let regularColor = Color(hex: 0xf6d2aa)
    let highlight: Bool
    
    var textColor: Color {
        highlight ? .white : regularTextColor
    }
    
    var color: Color {
        highlight ? .blue.lighter : regularColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: (configuration.isPressed ? .bottom : .top)) {
            if !configuration.isPressed {
                VStack {
                    Spacer().frame(maxHeight: shadowHeight)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(color.darker)
                }
            }
            
            VStack {
                if configuration.isPressed {
                    Spacer().frame(maxHeight: shadowHeight)
                }
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(color)
                if !configuration.isPressed {
                    Spacer().frame(maxHeight: shadowHeight)
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    configuration.label
                        .foregroundColor(textColor)
                    Spacer()
                }
                Spacer()
            }
            //                .offset(x: 0, y: configuration.isPressed ? shadowHeight : 0)
            //                .foregroundColor(textColor)
            //                .padding()
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(
            //            idealWidth: 100,
            maxWidth: 150)
        
        //        
        //            .padding()
        //            .background(.quaternary, in: Capsule())
        //            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

struct TileInHand: View {
    let letter: Letter
    let highlight: Bool
    let action: ()->()
    
    init(letter: Letter, action: @escaping (()->()) = { }) {
        self.letter = letter 
        self.highlight = false
        self.action = action 
    }
    
    init(letter: Letter, highlight: Bool, action: @escaping (()->()) = { }) {
        self.letter = letter 
        self.highlight = highlight
        self.action = action
    }
    
    var pointMessage: String {
        if letter.points == 1 {
            return "1 pt"
        }
        
        return "\(letter.points) pts"
    }
    
    var body: some View {
        Button(action: action, label: {
            ZStack {
                Text(verbatim: "\(letter.value)")
                                    .font(.system(size: 800))
                                    .fontWeight(.bold)
                                    
                //                    .fixedSize()
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(String(describing: letter.points))
                            .fixedSize()
                            .font(.caption)
                    }
                }
            }
            .minimumScaleFactor(0.001)
        })
            .buttonStyle(TileInHandButtonStyle(highlight: highlight))
    }
}

struct TileInHand_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TileInHand(letter: .init("A", points: 5))
            
            TileInHand(letter: .init("A", points: 5), highlight: true)
            
            HStack {
                TileInHand(letter: .init("A", points: 5))
                TileInHand(letter: .init("A", points: 5))
                TileInHand(letter: .init("A", points: 5))
                TileInHand(letter: .init("A", points: 5))
            }
            
            HStack {
                TileInHand(letter: .init("A", points: 5))
                TileInHand(letter: .init("A", points: 5))
                TileInHand(letter: .init("A", points: 5))
                TileInHand(letter: .init("A", points: 5))
                TileInHand(letter: .init("A", points: 5))
                TileInHand(letter: .init("A", points: 5))
                TileInHand(letter: .init("A", points: 5))
            }
        }
    }
}
