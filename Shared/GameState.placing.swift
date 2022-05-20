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
                
        self.boardView = BoardView(model: self.boardView.flattened(placed: data))
        self.startRefill(for: player, letters: data.placed)
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
