import SwiftUI

enum WordDirection : Equatable {
    case up
    case down 
    case right 
    case left
    
    func rotate() -> WordDirection {
        switch(self) {
            case .up: return .right
            case .right: return .down
            case .down: return .left
            case .left: return .up
        }
    }
}

enum TileModel : Equatable {
    case empty
    case choosing(WordDirection)
    case random
    case active
    case start
    
    static let startChoosing = TileModel.choosing(.right)
}
