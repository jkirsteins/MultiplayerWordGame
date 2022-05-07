import SwiftUI

/// Methods for swapping letters
extension GameState {
    func startSwapping(for player: PlayerIndex) {
        guard case .idle(player) = self.state else { return }
        self.state = .swapping(player, [])
    }
    
    func applySwap(for player: PlayerIndex) {
        guard case .swapping(player, let letters) = self.state, letters.count > 0 else {
            return
        }
        
        self.swapLetters(letters, for: player)
        self.state = .idle(player)
    }
    
    func swapLetters(_ letters: [IdLetter], for player: PlayerIndex)
    {
        guard let hand = self.hands.optGet(player) else {
            fatalError("Hand not found")
        }
        
        let handRemaining = hand.letters.filter { letter in
            !letters.contains(letter)
        }
        
        self.dispenser = LetterDispenser(
            letters: self.dispenser.remaining + letters)
        
        self.hands[player] = self.refill(PlayerHand(
            id: hand.id,
            letters: handRemaining))
    }
    
    func invertSwapState(for player: PlayerIndex) {
        guard 
            case .swapping(player, var swapState) = self.state,
            let letters = self.hands.optGet(player)?.letters
        else {
            return
        }
        
        swapState = letters.filter({ 
            letter in
            !swapState.contains(letter)
        })
        self.state = .swapping(player, swapState)
    }
    
    func cancelSwap(for player: PlayerIndex) {
        guard case .swapping(player, _) = self.state else { return }
        self.state = .idle(player)
    }
    
    func toggleSwapState(
        for player: PlayerIndex, 
        letter l: IdLetter) {
        guard case .swapping(player, var letters) = self.state else {
            return
        }
        
        if let ix = letters.firstIndex(of: l) {
            letters.remove(at: ix)
        } else {
            letters.append(l)
        }
        
        self.state = .swapping(player, letters)
    }
}
