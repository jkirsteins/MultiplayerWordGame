import SwiftUI

typealias LetterFrequency=(points: Int, count: Int)
typealias LetterFrequencies=[String:LetterFrequency]

struct LetterDispenser {
    let remaining: [IdLetter] 
    
    static func initialize(_ loc: Locale) -> [IdLetter] {
        switch(loc) {
        case .en_US:
            let freqs: LetterFrequencies = 
            [
                "": (0, 2),
                
                "E": (1, 12),
                "A": (1, 9),
                "I": (1, 9),
                "O": (1, 8),
                "N": (1, 6),
                "R": (1, 6),
                "T": (1, 6),
                "L": (1, 4),
                "S": (1, 4),
                "U": (1, 4),
                
                "D": (2, 4),
                "G": (2, 3),
                
                "B": (3, 2),
                "C": (3, 2),
                "M": (3, 2),
                "P": (3, 2),
                
                "F": (4, 2),
                "H": (4, 2),
                "V": (4, 2),
                "W": (4, 2),
                "Y": (4, 2),
                
                "K": (5, 1),
                
                "J": (8, 1),
                "X": (8, 1),
                
                "Q": (10, 1),
                "Z": (10, 1),
                
            ]
            
            let result: [Letter] = freqs.flatMap {
                kvp -> [Letter] in 
                
                let val: String = kvp.key
                let points: Int = kvp.value.0
                let count: Int = kvp.value.1
                
                let result: [Letter] = (0..<count).map { _ in
                    Letter(val, points: points)
                }
                return result
            }
            return result.map { $0.newUnique() }
            //    3 points: B ×2, C ×2, M ×2, P ×2
            //    4 points: F ×2, H ×2, V ×2, W ×2, Y ×2
            //    5 points: K ×1
            //    8 points: J ×1, X ×1
            //    10 points: Q ×1, Z ×1
        default:
            return []
        } 
    }
    
    init(letters: [IdLetter]) {
        self.remaining = letters
    }
    
    init(locale: Locale = .en_US) {
        self.remaining = Self.initialize(locale).shuffled()
    }
}

struct LetterDispenserTest: View {
    @State var l = LetterDispenser(locale: .en_US)
    
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        // default
        ScrollView {
            VStack {
                Text("Default for .en_US")
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(l.remaining) {
                        l in  
                        Text("\(l.letter.value) (\(l.letter.points) pts)")
                    }
                }
            }.padding()
        }
        
        // sorted
        ScrollView {
            VStack {
                Text("Sorted for .en_US")
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(l.remaining.sorted()) {
                        l in  
                        Text("\(l.letter.value) (\(l.letter.points) pts)")
                    }
                }
            }.padding()
        }
    }
}

struct LetterDispenserTest_Previews: PreviewProvider {
    static var previews: some View {
        LetterDispenserTest()
    }
}
