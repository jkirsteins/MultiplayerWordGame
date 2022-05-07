import SwiftUI

enum WordDirection : Equatable {
    case right
    case down 
    
    
    func rotate() -> WordDirection {
        switch(self) {
            case .right: return .down
            case .down: return .right
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
