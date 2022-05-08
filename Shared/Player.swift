import SwiftUI

struct Player {
    let index: PlayerIndex
    let color: Color
    
    static let unknown = Player(index: -1, color: .clear)
}

extension EnvironmentValues {
    var player: Player {
        get { self[PlayerKey.self] }
        set { self[PlayerKey.self] = newValue }
    }
}

private struct PlayerKey: EnvironmentKey {
    static let defaultValue = Player.unknown
}
