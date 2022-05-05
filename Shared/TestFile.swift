import SwiftUI

struct TDButtonModifier: ViewModifier {
    let model: TileModel
    let isCurrent: Bool
    
    func body(content: Content) -> some View {
        switch(model) {
        case .active:
            content.buttonStyle(TDButtonStyle(isCurrent: isCurrent))
        case .empty:
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
                        maxHeight: 50 - shadowHeight)
            }
            
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(color.lighter)
                .frame(
                    idealWidth: config.idealTileSize.width, 
                    idealHeight: config.idealTileSize.height - shadowHeight, 
                    maxHeight: 50 - shadowHeight)
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
                    maxHeight: 50)
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
                    maxHeight: 50)
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
                    maxHeight: 50)
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
    
    var body: some View {
        ZStack(alignment: .top) {
            TDButton(x: x, y: y)
                .frame(
                    minWidth: 50, idealWidth: config.idealTileSize.width, 
                    minHeight: 50, idealHeight: config.idealTileSize.height)
                .aspectRatio(1, contentMode: .fit)
        }
    }
}

extension CGSize {
    func div(_ by: CGFloat) -> CGSize {
        return CGSize(width: self.width / by, height: self.height / by)
    }
    
    func dec(_ by: CGFloat) -> CGSize {
        return CGSize(width: self.width - by, height: self.height - by)
    }
    
    func minsq() -> CGSize {
        let minside = min(self.width, self.height)
        return CGSize(width: minside, height: minside)
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

enum TileModel {
    case empty
    case random
    case active
    case start
}

struct BoardModel {
    let board: [TileModel]
    
    let rows: Int 
    let cols: Int
    
    private init(_ rows: Int, _ cols: Int, board: [TileModel]) {
        self.rows = rows 
        self.cols = cols 
        
        self.board = board
    }
    
    init(_ cols: Int, _ rows: Int) {
        self.rows = rows 
        self.cols = cols 
        
        let midx = Int(floor(CGFloat(cols)/2.0))
        let midy = Int(floor(CGFloat(rows)/2.0))
        
        let cutOffX = Int(floor(CGFloat(cols) / 5.0))
        let cutOffY = Int(floor(CGFloat(rows) / 5.0))
        
        let minDesired = 2
        
        var currentRandom = [0, 0, 0, 0]
        
        self.board =  
            (0..<rows).flatMap { y in
                (0..<cols).map { x in
                
                    let isBottom = y > midy
                    let isLeft = x < midx
                    let quadrant: Int
                    switch(isBottom, isLeft) {
                    case (false, false): quadrant = 0
                    case (true, false): quadrant = 1
                    case (false, true): quadrant = 2
                    case (true, true): quadrant = 3
                    } 
                    
                guard 
                    x != midx || y != midy
                else {
                    return .start
                }
                
                if (abs(midx - x) > cutOffX || abs(midy - y) > cutOffY) && drand48() < (0.04 * Double(minDesired - currentRandom[quadrant])) {
                    currentRandom[quadrant] += 1
                    return TileModel.random
                } else {
                    return TileModel.empty
                }
            }
        }
        
        // quick sanity check since the flatMap/map order
        // matters
        guard .start == board[midy*cols + midx] else {
            fatalError("Invalid board")
        }
    }
    
    func tileAt(x: Int, y: Int) -> TileModel {
        let ix = y*cols + x
        guard ix < self.board.count else {
            fatalError("Wrong index requested \(x) \(y) (cols \(cols) rows \(rows))")
        }
        
        let result = self.board[ix]
        return result
    }
    
    func changed(_ model: TileModel, x: Int, y: Int) -> BoardModel {
        var data = self.board
        data[y * cols + x] = model 
        return BoardModel(rows, cols, board: data)
    }
}

class GameState : ObservableObject {
    @Published var board = BoardModel(9, 9)
    
    var rows: Int { board.rows }
    var cols: Int  { board.cols }
    
    func tileAt(x: Int, y: Int) -> TileModel {
        self.board.tileAt(x: x, y: y)
    }
    
    func setType(_ model: TileModel, x: Int, y: Int) {
        self.board = self.board.changed(model, x: x, y: y)
    }
}

struct Game: View {
    @StateObject var state = GameState()
    
    var cols: Int { state.cols } 
    var rows: Int { state.rows }
    let spacing = CGFloat(2)
    
    var body: some View {
        GeometryReader { pr in 
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                Rows()
            }
            .environment(\.gridConfig, GridConfig(
                spacing: spacing, 
                idealTileSize: pr.size.div(CGFloat(cols)).dec(spacing).minsq(), 
                rows: rows, 
                cols: cols))
            .environmentObject(state)
            .debugBorder(.purple)
        }
        .environment(\.debug, false)
    }
}

struct TDView_Previews: PreviewProvider {
    static var previews: some View {
        Game()
    }
}
