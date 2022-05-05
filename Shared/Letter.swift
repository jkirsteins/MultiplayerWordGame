import SwiftUI

struct Letter : Hashable {
    let value: String
    let points: Int 
    
    init(_ value: String, points: Int) {
        self.value = value 
        self.points = points
    }
}
