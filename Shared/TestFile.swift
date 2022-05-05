import SwiftUI

struct TDButton: View {
    static var current: Binding<Bool>? = nil 
    @State var isCurrent: Bool = false
    
    var body: some View {
        Button("T") {
            if let prevIsCurrent = Self.current {
                prevIsCurrent.wrappedValue = false
            }
            Self.current = $isCurrent
            isCurrent = true
        }
        .buttonStyle(TDButtonStyle(isCurrent: isCurrent))
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

struct TDView: View {
    
    @Environment(\.gridConfig)
    var config: GridConfig 
    
    var shadowHeight: CGFloat {
        config.idealTileSize.height / 17.50
    }
    
    var cornerRadius: CGFloat {
        12.5
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            TDButton()
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
    
    var body: some View {
        HStack(spacing: config.spacing) {
            ForEach(0..<config.cols, id: \.self) { _ in
                TDView()
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
            ForEach(0..<config.rows, id: \.self) { _ in
                Row()
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

struct TDView_Previews: PreviewProvider {
    static let cols = 5
    static let rows = 2
    static let spacing = CGFloat(0.5) 
    
    static var previews: some View {
        GeometryReader { pr in 
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                Rows()
                Text(verbatim: "Ideal: \(pr.size.div(5).dec(2).minsq())")
            }
            .environment(\.gridConfig, GridConfig(
                spacing: spacing, 
                idealTileSize: pr.size.div(CGFloat(cols)).dec(spacing).minsq(), 
                rows: rows, 
                cols: cols))
            .debugBorder(.purple)
        }
        .environment(\.debug, false)
    }
}
