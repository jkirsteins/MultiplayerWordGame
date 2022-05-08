import SwiftUI

struct Point : Equatable, Hashable {
    let x: Int
    let y: Int
}

//struct Word : Equatable {
//    /// Identifiable letters instead of regular letters,
//    /// so we can map against the hand (and highlight)
//    let letters: [IdLetter]
//}

typealias PlayerIndex = Int

/// Letters chosen for swap
typealias LetterChoice = [IdLetter]

/// Exchanged letters (from->to)
typealias LetterSwap = [IdLetter:IdLetter]

extension PlayerIndex {
    static let first = 0
}

struct PlacingData : Equatable {
    let origin: Point
    let direction: WordDirection
    let placed: [IdLetter]
}

class GameState : ObservableObject {
    /// Basic state machine of the current turn
    enum GameStateOption : Equatable, CustomDebugStringConvertible {
        case idle(PlayerIndex) 
        case placing(PlayerIndex, PlacingData)
        case initializingSwap(PlayerIndex, LetterChoice)
        case animatingSwap(PlayerIndex, LetterSwap)
        
        var debugDescription: String {
            switch(self) {
                case .idle(let ix):
                return "Idle (for \(ix))"
            case .placing(let ix, let d):
                return "Placing word \(d.direction) (for \(ix))"
            case .initializingSwap(let ix, _):
                return "Choosing swap (for \(ix))"
            case .animatingSwap(let ix, _):
                return "Animating swap (for \(ix))"
            }
        }
        
        /// Fetch letters chosen for swapping (but not
        /// yet swapped)
        func getSwapChoice(
            for player: PlayerIndex) -> LetterChoice? 
        {
            switch(self) {
                case .initializingSwap(
                    player, let choice): 
                return choice
                default:
                return nil
            }
        }
        
        /// Fetch letters chosen for swapping once the
        /// choice is final
        func getSwap(
            for player: PlayerIndex) -> LetterSwap? 
        {
            switch(self) {
            case .animatingSwap(player, let swap): 
                return swap
            default:
                return nil
            }
        }
        
        /// Fetch current player index
        var player: PlayerIndex {
            switch(self) {
                case .idle(let ix): 
                return ix 
//                case .choosingDirection(let ix, _): 
//                return ix 
                case .placing(let ix, _): 
                return ix 
                case .initializingSwap(
                    let ix, _): 
                return ix
                case .animatingSwap(let ix, _):
                return ix
            }
        }
    }
    
    @Published var board: BoardModel
    @Published var dispenser: LetterDispenser
    
    @Published var hands: [PlayerHand]
    
    @Published var state: GameStateOption = .idle(.first)
    
    init(_ w: Int, _ h: Int, locale: Locale = .en_US) {
        self.board = BoardModel(w, h)
        
        let (firstHand, ld) = Self.refill(hand: PlayerHand(), dispenser: LetterDispenser(locale: locale))
        
        self.hands = [
            firstHand
        ]
        
        self.dispenser = ld
    }
    
    static func refill(
        hand: PlayerHand, 
        dispenser: LetterDispenser
    ) -> (PlayerHand, LetterDispenser) {
        let missing = 7 - hand.letters.count 
        let available = dispenser.remaining.count
        let toFetch = min(missing, available)
        
        let fetched = dispenser.remaining.prefix(toFetch)
        let remaining = dispenser.remaining.dropFirst(toFetch)
        
        let newDispenser = LetterDispenser(letters: Array(remaining))
        return (
            PlayerHand(
                id: hand.id, 
                letters: hand.letters + fetched),
            newDispenser)
    }
    
    var rows: Int { board.rows }
    var cols: Int  { board.cols }
    
    func tileAt(x: Int, y: Int) -> TileModel {
        self.board.tileAt(x: x, y: y)
    }
    
    func setType(_ model: TileModel, x: Int, y: Int) {
        self.board = self.board.changed(model, x: x, y: y)
    }
    
    var existingChoiceStashed: (Int, Int, TileModel)? = nil
    
    
    func resetExistingChoice() {
        if let stashPop = existingChoiceStashed {
            self.setType(
                stashPop.2, 
                x: stashPop.0, 
                y: stashPop.1)
        } 
        self.existingChoiceStashed = nil
    }
    
    func tryStart(x: Int, y: Int) {
        let existing = self.tileAt(x: x, y: y)
        
        switch (existing) {
            case .letter(_):
            return
            case .start, .empty, .random, .active:
            resetExistingChoice()
            existingChoiceStashed = (x, y, existing)
            self.setType(
                .startChoosing, 
                x: x, 
                y: y)
            case .choosing(let dir):
            self.setType(
                .choosing(dir.rotate()), 
                x: x, 
                y: y)
        }
    }
}

