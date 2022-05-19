import SwiftUI

fileprivate let MAX_SIDE = CGFloat(50 )

struct TDButtonModifier: ViewModifier {
    let model: TileModel
    let isCurrent: Bool
    
    func body(content: Content) -> some View {
        switch(model) {
            case .choosing(_):
            content.buttonStyle(TDButtonStyle(isCurrent: false))
        case .active:
//            content.buttonStyle(TDButtonStyle(isCurrent: isCurrent))
            content.buttonStyle(TDEmptyButtonStyle())
        case .empty, .letter(_):
            content.buttonStyle(TDEmptyButtonStyle())
        case .start:
            content.buttonStyle(TDStartButtonStyle())
        case .random:
            content.buttonStyle(TDRandomButtonStyle())
        }
    }
}

struct TDButton: View {
    static var current: Binding<Bool>? = nil 
    @State var isCurrent: Bool = false
    @EnvironmentObject var state: GameState
    
    let title: String 
    let x: Int 
    let y: Int 
    
    var model: TileModel {
        state.tileAt(x: x, y: y)
    }
    
    init(x: Int, y: Int) {
        self.x = x 
        self.y = y
        self.title = "\(x) \(y)"
    }
    
    var body: some View {
        Button(title) {
            if let prevIsCurrent = Self.current {
                prevIsCurrent.wrappedValue = false
            }
            Self.current = $isCurrent
            isCurrent = true
            
            self.state.setType(.active, x: x, y: y)
        }
        .modifier(
            TDButtonModifier(model: model, isCurrent: isCurrent)
        )
    }
}

struct TDStartButton: View {
    @EnvironmentObject var state: GameState
    
    let x: Int 
    let y: Int 
    
    var model: TileModel {
        state.tileAt(x: x, y: y)
    }
    
    init(x: Int, y: Int) {
        self.x = x 
        self.y = y
    }
    
    var title: String {
        guard case let .choosing(direction) = model else {
            return ""
        }
        
        switch(direction) {
        case .down: return "V"
        case .right: return ">"
        }
    }
    
    var body: some View {
        Button(title) {
            self.state.tryStart(x: x, y: y)
        }
        .modifier(
            TDButtonModifier(model: model, isCurrent: false)
        )
    }
}

struct TDButtonStyle: ButtonStyle {
    @Environment(\.gridConfig)
    var config: GridConfig
    
    let isCurrent: Bool
    
    var shadowHeight: CGFloat {
        //        config.idealTileSize.height / 17.50
        6.0
    }
    
    var cornerRadius: CGFloat {
        12.5
    }
    
    var color: Color {
        isCurrent ? .blue : .red
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: (configuration.isPressed ? .bottom : .top)) {
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(color.darker)
                    .frame(
                        idealWidth: config.idealTileSize.width, 
                        idealHeight: config.idealTileSize.height - shadowHeight, 
                        maxHeight: MAX_SIDE - shadowHeight)
            }
            
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(color.lighter)
                .frame(
                    idealWidth: config.idealTileSize.width, 
                    idealHeight: config.idealTileSize.height - shadowHeight, 
                    maxHeight: MAX_SIDE - shadowHeight)
                .aspectRatio(1, contentMode: .fit)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    configuration.label
                        .padding(.top, configuration.isPressed ? shadowHeight : 0 )
                        .foregroundColor(.white)
                        .padding(2)
                    Spacer()
                }
                Spacer()
            }
        }
        //        configuration.label
        //            .padding()
        //            .background(.quaternary, in: Capsule())
        //            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat = 1) -> some View {
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

extension InsettableShape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat = 1) -> some View {
        self
            .strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

struct TDEmptyButtonStyle: ButtonStyle {
    @Environment(\.gridConfig)
    var config: GridConfig
    
    let color = Color.gray
    
    var cornerRadius: CGFloat {
        12.5
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: (configuration.isPressed ? .bottom : .top)) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.white, strokeBorder: .gray)
                .frame(
                    idealWidth: config.idealTileSize.width, 
                    idealHeight: config.idealTileSize.height, 
                    maxHeight: MAX_SIDE)
                .aspectRatio(1, contentMode: .fit)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    configuration.label
                        .foregroundColor(.gray)
                        .padding(2)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct TDStartButtonStyle: ButtonStyle {
    @Environment(\.gridConfig)
    var config: GridConfig
    
    let color = Color.green
    
    var cornerRadius: CGFloat {
        12.5
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: (configuration.isPressed ? .bottom : .top)) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.green)
                .frame(
                    idealWidth: config.idealTileSize.width, 
                    idealHeight: config.idealTileSize.height, 
                    maxHeight: MAX_SIDE)
                .aspectRatio(1, contentMode: .fit)
            
            VStack {
                HStack {
                    Image(systemName: "star.circle.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .padding(12)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity)
                }
            }
        }
    }
}

struct TDRandomButtonStyle: ButtonStyle {
    @Environment(\.gridConfig)
    var config: GridConfig
    
    let color = Color.gray
    
    var cornerRadius: CGFloat {
        12.5
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: (configuration.isPressed ? .bottom : .top)) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.white, strokeBorder: .gray)
                .frame(
                    idealWidth: config.idealTileSize.width, 
                    idealHeight: config.idealTileSize.height, 
                    maxHeight: MAX_SIDE)
                .aspectRatio(1, contentMode: .fit)
            
            Text("?")
                .foregroundColor(color)
                .fontWeight(.bold)
                .font(.system(size: 100))
                .minimumScaleFactor(0.01)
                .padding(6)
        }
    }
}

struct TDView: View {
    
    @Environment(\.gridConfig)
    var config: GridConfig 
    
    @EnvironmentObject
    var gameState: GameState
    
    let x: Int 
    let y: Int 
    
    var shadowHeight: CGFloat {
        config.idealTileSize.height / 17.50
    }
    
    var cornerRadius: CGFloat {
        12.5
    }
    
    var model: TileModel {
        gameState.tileAt(x: x, y: y)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            switch(model) {
                case .empty, .choosing(_), .start, .random:
                TDStartButton(x: x, y: y)
                default:
            TDButton(x: x, y: y)
                .frame(
                    minWidth: MAX_SIDE, idealWidth: config.idealTileSize.width, 
                    minHeight: MAX_SIDE, idealHeight: config.idealTileSize.height)
                .aspectRatio(1, contentMode: .fit)
            }
        }
    }
}

extension CGSize {
    func div(_ by: CGFloat) -> CGSize {
        return CGSize(width: self.width / by, height: self.height / by)
    }
    
    func mul(_ by: CGFloat) -> CGSize {
        return CGSize(width: self.width * by, height: self.height * by)
    }
    
    func dec(_ by: CGFloat) -> CGSize {
        return CGSize(width: self.width - by, height: self.height - by)
    }
    
    var roundedStr: String {
        let x = String(format: "%.2f", self.width)
        let y = String(format: "%.2f", self.width)
        return "(\(x), \(y))"
    }
    
    func minsq() -> CGSize {
        let minside = min(self.width, self.height)
        return CGSize(width: minside, height: minside)
    }
    
    func maxsq() -> CGSize {
        let maxside = max(self.width, self.height)
        return CGSize(width: maxside, height: maxside)
    }
}

struct Row: View {
    @Environment(\.gridConfig)
    var config: GridConfig 
    
    let y: Int 
    
    var body: some View {
        HStack(spacing: config.spacing) {
            ForEach(0..<config.cols, id: \.self) { ix in
                TDView(x: ix, y: y)
            }
        }
        .debugBorder(.purple)
    }
}

struct Rows: View {
    @Environment(\.gridConfig)
    var config: GridConfig 
    
    var body: some View {
        VStack(spacing: config.spacing) {
            ForEach(0..<config.rows, id: \.self) { ix in
                Row(y: ix)
            }
        }
        .debugBorder(.green)
    }
}

extension View {
    func debugBorder(_ color: Color) -> some View {
        self.modifier(DebugBorderModifier(color: color))
    }
}

struct DebugBorderModifier: ViewModifier {
    @Environment(\.debug)
    var debug: Bool
    
    let color: Color 
    
    func body(content: Content) -> some View {
        content
            .border(debug ? color : .clear)
    }
}

struct GridConfig {
    let spacing: CGFloat
    let idealTileSize: CGSize
    let rows: Int 
    let cols: Int
}

private struct DebugKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var debug: Bool {
        get { self[DebugKey.self] }
        set { self[DebugKey.self] = newValue }
    }
}

private struct GridConfigKey: EnvironmentKey {
    static let defaultValue = GridConfig(spacing: 0, idealTileSize: .zero, rows: 0, cols: 0)
}

extension EnvironmentValues {
    var gridConfig: GridConfig {
        get { self[GridConfigKey.self] }
        set { self[GridConfigKey.self] = newValue }
    }
}

struct PlayerHand : Equatable, Identifiable {
    let id: UUID
    let letters: [IdLetter]
    
    init() {
        self.id = UUID()
        self.letters = []
    }
    
    init(id: UUID, letters: [IdLetter]) {
        self.id = id
        self.letters = letters
    }
}

struct TDView_Previews: PreviewProvider {
    static var previews: some View {
        Game()
    }
}
