import SwiftUI

struct WordModel : Codable, Equatable, CustomDebugStringConvertible {
    static func == (lhs: WordModel, rhs: WordModel) -> Bool {
        lhs.word == rhs.word
    }
    
    enum CodingKeys: String, CodingKey {
        case word 
    }
    
    let word: [CharacterModel]
    
    init(_ word: String, locale: Locale) {
        self.word = word.map {
            CharacterModel(value: $0, locale: locale)
        }
    }
    
    init() {
        self.word = []
    }
    
    init(characters: [CharacterModel]) {
        self.word = characters
    }
    
    var displayValue: String {
        self.word.map {
            $0.displayValue
        }.joined()
    }
    
    var locale: Locale {
        // if word is empty, don't crash
        guard self.word.count > 0 else {
            return .current
        }
        
        guard let firstLocale = self.word.first?.locale,
              self.word.allSatisfy({ $0.locale == firstLocale }) else {
                  fatalError("All characters in a word must have the same locale.")
              }
        
        return firstLocale
    }
    
    var debugDescription: String {
        self.word.map({ $0.debugDescription }).joined(separator: "")
    }
    
    var count: Int {
        self.word.count
    }
    
    subscript(_ ix: Int) -> CharacterModel {
        self.word[ix]
    }
    
    func dropLast() -> WordModel {
        WordModel(
            characters: word.dropLast())
    }
    
    func contains(_ element: CharacterModel) -> Bool {
        self.word.contains(element)
    }
}

struct InternalWordModelTests: View {
    let lvLV = Locale(identifier: "lv_LV")
    let frLV = Locale(identifier: "fr_LV")
    let enUS = Locale(identifier: "en_US")
    
    struct Comparison: View {
        let desc: String 
        let left: WordModel?
        let right: WordModel?
        let shouldMatch: Bool
        
        var body: some View {
            let match = left == right
            let good = (shouldMatch && match) || (!shouldMatch && !match)
            
            return VStack(alignment: .leading) {
                Text("Comparison: \(desc)")
                Text(verbatim: "\(left?.debugDescription ?? "none") \(match ? "==" : "!=") \(right?.debugDescription ?? "none")").foregroundColor(good ? .green : .red)
            }.border(.gray)
        }
    }
    
    var body: some View {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let codeTest = WordModel("coder", locale: lvLV)
        
        let encoded = try! encoder.encode(codeTest)
        let decoded = try? decoder.decode(WordModel.self, from: encoded)
        
        let encodedString = try! encoder.encode("coder")
        let decodedFromString = try? decoder.decode(WordModel.self, from: encodedString)
        
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Regular character tests").font(.largeTitle)
            
            Group {
                Comparison(
                    desc: "Codable (from/to WordModel)", 
                    left: codeTest, 
                    right: decoded, 
                    shouldMatch: true)
                Comparison(
                    desc: "Codable (from String)", 
                    left: codeTest, 
                    right: decodedFromString, 
                    shouldMatch: true)
                Comparison(
                    desc: "Case-insensitive match", 
                    left: WordModel("acorn", locale: enUS), 
                    right: WordModel("ACORN", locale: enUS), 
                    shouldMatch: true)
                Comparison(
                    desc: "Mismatch", 
                    left: WordModel("acorn", locale: enUS), 
                    right: WordModel("blues", locale: enUS), 
                    shouldMatch: false)
                Comparison(
                    desc: "Diacritic sensitive match (lv)", 
                    left: WordModel("š", locale: lvLV),
                    right: WordModel("s", locale: lvLV), 
                    shouldMatch: false)
                Comparison(
                    desc: "Diacritic insensitive match (fr)", 
                    left: WordModel("é", locale: frLV),
                    right: WordModel("e", locale: frLV), 
                    shouldMatch: true)
                Comparison(
                    desc: "Locale mismatch", 
                    left: WordModel("e", locale: enUS),
                    right: WordModel("e", locale: frLV), 
                    shouldMatch: false)
                }
        }
    }
}

struct InternalWordModelTests_Previews: PreviewProvider {
    static var previews: some View {
        InternalWordModelTests()
    }
}
