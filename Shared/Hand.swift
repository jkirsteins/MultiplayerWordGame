import SwiftUI

struct HandRow: View {
    
    @Environment(\.player)
    var player: Player
    
    @EnvironmentObject
    var state: GameState
    
    var hand: PlayerHand? {
        state.hands.optGet(player.index)
    }
    
    var swapChoice: LetterChoice {
        state.state.getSwapChoice(for: player.index) ?? []
    }
    
    var swap: LetterSwap {
        state.state.getSwap(for: player.index) ?? [:]
    }
    
    /// Returns true if we are picking letters for swap
    var isChoosingSwap: Bool {
        switch(state.state) {
        case .initializingSwap(player.index, _): 
            return true
        default: return false
        }
    }
    
    func shouldHighlight(_ l: IdLetter) -> Bool {
        swapChoice.contains(l) || swap.keys.contains(l)
    }
    
    func flipLetter(for letter: IdLetter) -> Letter? {
        swap[letter]?.letter
    }
    
    @State var flippedSwapped = 0
    
    var body: some View {
        if let letters = hand?.letters {
            HStack {
                ForEach(letters) {
                    l in 
                    
                    FlippableTileInHand(
                        letter: l.letter, 
                        highlight: shouldHighlight(l),
                        flipped: flipLetter(for: l),
                        flipCallback: {
                            flippedSwapped += 1
                        }) 
                    {
                        if isChoosingSwap {
                            state.toggleSwapChoice(
                                for: player.index, 
                                   letter: l)
                        } else {
                            print("Nothing to do with \(l.letter.value)")
                        }
                    }
                    .frame(
                        minWidth: 30,
                        minHeight: 30)
                }
            }
            .onChange(of: self.flippedSwapped) {
                newCount in 
                guard self.swap.keys.count > 0 else {
                    return
                }
                
                if newCount == self.swap.keys.count {
                    self.state.finalizeSwap(for: player.index)
                }
            }
        }
    }
}

struct IdleHand: View {
    @EnvironmentObject
    var state: GameState
    
    @Environment(\.player)
    var player: Player
    
    var hand: PlayerHand? {
        state.hands.optGet(player.index)
    }
    
    var body: some View {
        HandRow()
        
        HStack {
            if case .idle(player.index) = state.state {
                Button("Swap") {
                    state.startSwapping(for: player.index)
                }
                
                Button("Submit") {
                    
                }
            }
        }
    }
}

struct SwappingHand: View {
    
    @EnvironmentObject
    var state: GameState
    
    @Environment(\.player)
    var player: Player
    
    var choice: LetterChoice? {
        state.state.getSwapChoice(for: player.index)
    }
    
    var swap: LetterSwap? {
        state.state.getSwap(for: player.index)
    }
    
    var body: some View {
        VStack {
            Text("Please select the letters you wish to swap.")
            
            HandRow()
            
            VStack(spacing: 8) {
                Button("Apply swap") {
                    self.state.startSwap(for: player.index)
                }
                .disabled( (choice?.count ?? 0) < 1 )
                
                Button("Cancel swap") {
                    self.state.cancelSwap(for: player.index)
                }
                .disabled(choice == nil)
                
                Button("Invert swap") {
                    self.state.invertSwapState(for: player.index)
                }
                .disabled(choice == nil)
            }
        }
    }
}
struct Hand: View {
    @EnvironmentObject
    var state: GameState
    
    @Environment(\.player)
    var player: Player
    
    var body: some View {
        switch(state.state) {
        case .initializingSwap(player.index, _), .animatingSwap(player.index, _):
            SwappingHand()
        default:
            IdleHand()
        }
    }
}

struct Hand_Previews: PreviewProvider {
    static var previews: some View {
        //        Hand()
        Text("todo")
    }
}
