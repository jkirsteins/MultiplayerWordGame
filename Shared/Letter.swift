import SwiftUI

struct IdLetter : Identifiable, Comparable {
    let id = UUID()
    var letter: Letter 
    
    static func < (lhs: IdLetter, rhs: IdLetter) -> Bool {
        lhs.letter < rhs.letter
    }
}  

struct Letter : Hashable, Comparable {
    let value: String
    let points: Int 
    
    static func < (lhs: Letter, rhs: Letter) -> Bool {
        lhs.value < rhs.value
    }
    
    init(_ value: String, points: Int) {
        self.value = value 
        self.points = points
    }
    
    func newUnique() -> IdLetter {
        IdLetter(letter: self)
    }
}
