import SwiftUI

struct RevealModifier<Revealed: View>: ViewModifier {
    
    let duration: Double
    let callback: ()->()
    let revealed: Revealed
    
    @State private var currentStep: Int = 0
    @State private var degrees: CGFloat = 0.0
    
    init(
        duration: Double, 
        callback: @escaping ()->(), 
        @ViewBuilder revealed: ()->Revealed) {
            self.duration = duration 
            self.callback = callback 
            self.revealed = revealed()
        }
    
    func degreesForStep(_ step: Int) -> CGFloat {
        
        max(
            0.0, 
            89.99 + (
                90.0 * CGFloat(step-1)
            )
        )
        
    }
    
    func anim(for step: Int) -> Animation {
        switch(step) {
        case 1:
            return .easeIn(duration: duration)
        case 2:
            return .easeOut(duration: duration)
        default:
            return .linear(duration: duration)
        }
        
    }
    
    func body(content: Content) -> some View {
        Group {
            if currentStep == 0 || currentStep == 1 {
                content
            } else {
                revealed
                    .rotation3DEffect(
                        .degrees(180), 
                        axis: (1, 0, 0), 
                        perspective: 0.0
                    )
            }
        }
        .onAnimationCompleted(for: degrees, completion: {
            guard currentStep < 2 else {
                callback()
                return
            }
            currentStep += 1
            withAnimation(anim(for: currentStep)) {
                degrees = degreesForStep(currentStep)
            }
        })
        .rotation3DEffect(
            .degrees(degrees), 
            axis: (1, 0, 0), 
            perspective: 0.0
        )
        .onAppear {
            currentStep = 1
            withAnimation(anim(for: currentStep)) 
            {
                degrees = degreesForStep(currentStep)
            }
        }
    }
}

extension View {
    //    func blinking(duration: Double = 0.75) -> some View {
    //        modifier(BlinkViewModifier(duration: duration))
    //    }
}

struct RevealModifierTestView: View {
    let from = Letter("A", points: 5)
    
    @State var to: Letter? = nil
    @State var uuid = UUID()
    
    var body: some View {
        VStack(spacing: 24) {
            FlippableTileInHand(
                letter: from, 
                highlight: .selected, 
                flipped: to,
                flipCallback: {
                    to = nil
                    uuid = UUID()
                },
                action: {
                    print("Clicked")
                })
                .id(uuid)
            
            Button("Flip") {
                to = Letter("B", points: 2)
            }
        }
    }
}

struct RevealModifier_Previews: PreviewProvider {
    static var previews: some View {
        RevealModifierTestView()
    }
}
