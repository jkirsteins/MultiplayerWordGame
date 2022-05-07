import SwiftUI

struct Point : Equatable {
    let x: Int
    let y: Int
}

struct Word : Equatable {
    let letters: [Letter]
}

typealias PlayerIndex = Int
typealias SwapState = [IdLetter]

extension PlayerIndex {
    static let first = 0
}

class GameState : ObservableObject {
    /// Basic state machine of the current turn
    enum State : Equatable {
        case idle(PlayerIndex) 
        case choosingDirection(PlayerIndex, WordDirection)
        case placing(PlayerIndex, Point, WordDirection, Word)
        case swapping(PlayerIndex, SwapState)
        
        /// Fetch swap state for a given player
        /// (if the turn state is swapping)
        func getSwapState(
            for player: PlayerIndex) -> SwapState? 
        {
            switch(self) {
                case .swapping(player, let state): 
                return state
                default:
                return nil
            }
        }
        
        /// Fetch current player index
        var player: PlayerIndex {
            switch(self) {
                case .idle(let ix): return ix 
                case .choosingDirection(let ix, _): return ix 
                case .placing(let ix, _, _, _): return ix 
                case .swapping(let ix, _): return ix
            }
        }
    }
    
    @Published var board: BoardModel
    @Published var dispenser: LetterDispenser
    
    @Published var hands: [PlayerHand]
    
    @Published var state: State = .idle(0)
    
    init(locale: Locale = .en_US) {
        var dispenser = LetterDispenser(locale: locale)
        
        self.board = BoardModel(7, 7)
        
        self.hands = [
            Self.refill(PlayerHand(), &dispenser)
        ]
        
        self.dispenser = dispenser
    }
    
    func refill(_ hand: PlayerHand) -> PlayerHand {
        Self.refill(hand, &dispenser)
    }
    
    static func refill(
        _ hand: PlayerHand, 
        _ dispenser: inout LetterDispenser
    ) -> PlayerHand {
        let missing = 7 - hand.letters.count 
        let available = dispenser.remaining.count
        let toFetch = min(missing, available)
        
        let fetched = dispenser.remaining.prefix(toFetch)
        let remaining = dispenser.remaining.dropFirst(toFetch)
        
        dispenser = LetterDispenser(letters: Array(remaining))
        return PlayerHand(
            id: hand.id, 
            letters: hand.letters + fetched)
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

