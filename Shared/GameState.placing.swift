import SwiftUI

extension GameState {
    func placingData(for player: PlayerIndex) -> PlacingData? {
        guard 
            case .placing(player, let data) = state 
        else {
            return nil
        }
        
        return data
    }
    
    func isPlacing(for player: PlayerIndex) -> Bool {
        placingData(for: player) != nil
    }
    
    func applyPlacing(for player: PlayerIndex) {
        guard 
            let data = placingData(for: player) 
        else { 
            return 
        }
        
        let stride = (
            data.direction == .right ? 1 : board.cols)
        
        let originIx = data.origin.y * board.cols + data.origin.x
        
        var tiles = board.board
        
        for ix in 0..<data.placed.count {
            let l = data.placed[ix]
            let boardIx = originIx + ix * stride
            tiles[boardIx] = .letter(l.letter)
        } 
        
        self.board = self.board.replaced(with: tiles)
        self.state = .idle(player)
    }
    
    func cancelPlacing(for player: PlayerIndex) {
        guard isPlacing(for: player) else { return }
        
        self.state = .idle(player)
    }
    
    func togglePlace(
        letter: IdLetter, 
        for player: PlayerIndex)
    {
        guard case .placing(
            player, 
            let data) = state 
        else {
            return 
        }
        
        let newLetters: [IdLetter] 
        if data.placed.contains(letter) {
            newLetters = data.placed.filter { 
                $0 != letter 
            } 
        } else {
            newLetters = data.placed + [letter]
        }
        
        self.state = .placing(
            player, 
            PlacingData(
                origin: data.origin, 
                direction: data.direction, 
                placed: newLetters))
    }
    
    func getPlaced(for player: PlayerIndex) -> [IdLetter]? {
        self.placingData(for: player)?.placed
    }
    
    func startPlacing(
        for player: PlayerIndex, 
        at point: Point
    ) {
        switch(state) {
        case .idle(player), .placing(player, _):
            break 
        default:
            return
        }
        
        let data = self.placingData(for: player)
        let direction: WordDirection = data?.direction.rotate() ?? .right
        
        self.state = .placing(
            player, 
            PlacingData(
                origin: point, 
                direction: direction, 
                placed: []))
    }
}
