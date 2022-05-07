import SwiftUI

extension GameState {
    func place(
        letter: IdLetter, 
        for player: PlayerIndex)
    {
        guard case .placing(
            player, 
            let point, 
            let dir, 
            let word) = state 
        else {
            return 
        }
        
        let newLetters = word.letters + [letter]
        self.state = .placing(player, point, dir, Word(letters: newLetters))
    }
    
    func getPlaced(for player: PlayerIndex) -> [IdLetter]? {
        guard case .placing(
            player, 
            _, 
            _, 
            let word) = state 
        else {
            return nil
        }
        
        return word.letters
    }
    
    func startPlacing(
        for player: PlayerIndex, 
        at point: Point
    ) {
        switch(state) {
        case .idle(player), .placing(player, _, _, _):
            break 
        default:
            return
        }
        
        let direction: WordDirection
        if case .placing(player, point, let existingDirection, _) = self.state {
            direction = existingDirection.rotate()
        } else {
            direction = .right
        }
        
        print("Placing at", point)
        self.state = .placing(player, point, direction, Word(letters: []))
    }
}
