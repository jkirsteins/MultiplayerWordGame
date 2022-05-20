import SwiftUI

/// Methods for swapping letters
extension GameState {
    func startSwapping(for player: PlayerIndex) {
        guard case .idle(player) = self.state else { return }
        self.state = .initializingSwap(player, [])
    }
    
    /// Start animating the swap that was not initiated by the player
    func startRefill(for player: PlayerIndex, letters: [IdLetter]) {
        let swap = self.refillLetters(letters, for: player)
        self.state = .animatingSwap(player, swap)
    }
    
    /// Start animating the swap
    func startSwap(for player: PlayerIndex) {
        guard 
            case .initializingSwap(
                player, let letters
            ) = self.state, 
                letters.count > 0
        else {
            return
        }
        
        let swap = self.swapLetters(letters, for: player)
        self.state = .animatingSwap(player, swap)
    }
    
    /// Finalize swap (post animation)
    func finalizeSwap(for player: PlayerIndex) {
        guard let hand = self.hands.optGet(player) else {
            fatalError("Hand not found")
        }
        
        guard 
            case .animatingSwap(
                player, let swap
            ) = self.state
        else {
            return
        }
        
        self.hands[player] = PlayerHand(
            id: hand.id, 
            letters: hand.letters.map { l in
                swap[l] ?? l
            }) 
        
        self.state = .idle(player)
    }
    
    func refillLetters(_ placed: [IdLetter], for player: PlayerIndex) -> LetterSwap
    {
        let refillCount = min(placed.count, dispenser.remaining.count)
        let refilled = dispenser.remaining.prefix(refillCount)
        let remaining = dispenser.remaining.dropFirst(refillCount)
        
        self.dispenser = LetterDispenser(
            letters: Array(remaining))
        
        return Dictionary(uniqueKeysWithValues: zip(placed, refilled))
    }
    
    func swapLetters(_ swapped: [IdLetter], for player: PlayerIndex) -> LetterSwap
    {
        guard dispenser.remaining.count >= swapped.count 
        else {
            return [:]
        }
        
        let swappedFor = dispenser.remaining.prefix(swapped.count)
        
        let remaining = dispenser.remaining.dropFirst(swapped.count)
        
        self.dispenser = LetterDispenser(
            letters: remaining + swapped)
        
        return Dictionary(uniqueKeysWithValues: zip(swapped, swappedFor))
    }
    
    func invertSwapState(for player: PlayerIndex) {
        guard 
            case .initializingSwap(player, var choice) = self.state,
            let letters = self.hands.optGet(player)?.letters
        else {
            return
        }
        
        choice = letters.filter({ 
            letter in
            !choice.contains(letter)
        })
        self.state = .initializingSwap(player, choice)
    }
    
    func cancelSwap(for player: PlayerIndex) {
        guard case .initializingSwap(player, _) = self.state else { 
            return 
        }
        self.state = .idle(player)
    }
    
    func toggleSwapChoice(
        for player: PlayerIndex, 
        letter l: IdLetter) 
    {
        guard 
            case .initializingSwap(
                player, var letters) = self.state 
        else {
            return
        }
        
        if let ix = letters.firstIndex(of: l) {
            letters.remove(at: ix)
        } else {
            letters.append(l)
        }
        
        self.state = .initializingSwap(player, letters)
    }
}
