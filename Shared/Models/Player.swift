import SwiftUI
import GameKit

//struct Player {
//    let index: PlayerIndex
//    let color: Color
//
//    static let unknown = Player(index: -1, color: .clear)
//}

struct PlayerData {
    let index: PlayerIndex
    let color: Color
}

enum Player {
    case unknown
    case local(PlayerData)
    case online(GKTurnBasedParticipant, PlayerData)
    
    var index: PlayerIndex {
        self.data.index
    }
    
    var color: Color {
        self.data.color
    }
    
    var data: PlayerData {
        switch(self) {
        case .unknown:
            fatalError("Do not use .unknown")
        case .local(let data):
            return data
        case .online(_, let data):
            return data
        }
    }
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
