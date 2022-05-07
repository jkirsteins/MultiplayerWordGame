import SwiftUI

struct FlippableTileInHand: View {
    let letter: Letter
    let highlight: Bool
    
    let flipped: Letter?
    let flipCallback: ()->()
    let action: ()->()
    
    var body: some View {
        Group {
            if flipped == nil {
                TileInHand(
                    letter: letter, 
                    highlight: highlight,
                    action: action)
            } 
            
            if let flipped = flipped {
                TileInHand(
                    letter: letter, 
                    highlight: highlight,
                    action: action)
                    .modifier(
                        RevealModifier(
                            duration: 0.5, 
                            callback: {
                                flipCallback()
                            },
                            revealed: {
                                TileInHand(
                                    letter: flipped, 
                                    highlight: false)
                            }
                        )
                    )
            }
        }
    }
}
