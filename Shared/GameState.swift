import SwiftUI

class GameState : ObservableObject {
    @Published var board: BoardModel
    @Published var dispenser: LetterDispenser
    
    @Published var hands: [PlayerHand]
    
    init(locale: Locale = .en_US) {
        var dispenser = LetterDispenser(locale: locale)
        
        self.board = BoardModel(3, 3)
        
        self.hands = [
            Self.refill(PlayerHand(), &dispenser)
        ]
        
        self.dispenser = dispenser
    }
    
    func refill(_ hand: PlayerHand) -> PlayerHand {
        Self.refill(hand, &dispenser)
    }
    
    static func refill(_ hand: PlayerHand, _ dispenser: inout LetterDispenser) -> PlayerHand {
        let missing = 7 - hand.letters.count 
        let available = dispenser.remaining.count
        let toFetch = min(missing, available)
        
        let fetched = dispenser.remaining.prefix(toFetch)
        let remaining = dispenser.remaining.dropFirst(toFetch)
        
        dispenser = LetterDispenser(letters: Array(remaining))
        return PlayerHand(letters: hand.letters + fetched)
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

