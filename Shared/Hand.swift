import SwiftUI

struct HandRow: View {
    
    @Environment(\.player)
    var player: Player
    
    @EnvironmentObject
    var state: GameState
    
    var hand: PlayerHand? {
        state.hands.optGet(player.index)
    }
    
    var swapState: [IdLetter] {
        state.state.getSwapState(for: player.index) ?? []
    }
    
    var isSwapping: Bool {
        switch(state.state) {
        case .swapping(player.index, _): return true 
        default: return false
        }
    }
    
    var body: some View {
        if let letters = hand?.letters {
            HStack {
                ForEach(letters) {
                    l in 
                    
                    TileInHand(
                        letter: l.letter, 
                        highlight: swapState.contains(l)) 
                    {
                        if isSwapping {
                            state.toggleSwapState(
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
    
    var swapState: SwapState? {
        state.state.getSwapState(for: player.index)
    }
    
    var body: some View {
        VStack {
            if let swapState = self.swapState {
                Text("Please select the letters you wish to swap.")
                
                HandRow()
                
                VStack(spacing: 8) {
                    Button("Apply swap") {
                        self.state.applySwap(for: player.index)
                    }
                    .disabled(swapState.isEmpty)
                    
                    Button("Cancel swap") {
                        self.state.cancelSwap(for: player.index)
                    }
                    
                    Button("Invert swap") {
                        self.state.invertSwapState(for: player.index)
                    }
                }
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
        case .swapping(player.index, _):
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
