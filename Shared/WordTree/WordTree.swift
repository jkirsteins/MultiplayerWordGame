import SwiftUI

fileprivate class BranchNode {
    var children = Set<Node>()
}

fileprivate func letterNumberMsg(_ ix: Int) -> String {
    guard let ordinal = (ix+1).ordinal else {
        return "Letter \(ix+1)"
    }
    
    return "\(ordinal) letter"
}

fileprivate class Node : BranchNode, Hashable {
    let char: CharacterModel
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(char)
        hasher.combine(children)
    }
    
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.char == rhs.char &&
        lhs.children == rhs.children
    }
    
    init(char: CharacterModel) {
        self.char = char
        super.init()
    }
}

class WordTree {
    fileprivate let root = BranchNode()
    
    let locale: Locale
    var count: Int = 0
    
    init(locale: Locale) {
        self.locale = locale 
    }
    
    init(words: [WordModel], locale: Locale) {
        self.locale = locale
        
        for word in words {
            let _ = self.add(characters: word.word)
        }
    }
    
    func add(word: String) -> Bool {
        return self.add(characters: word.map({ 
            CharacterModel(value: $0, locale: locale) 
        }))
    }
    
    fileprivate func add(characters: [CharacterModel]) -> Bool {
        guard characters.count == 5 else { return false }
        
        defer {
            count += 1
        }
        
        var node: BranchNode = self.root
        
        for char in characters {
            if let nextNode = node.children.first(where: { $0.char == char }) {
                node = nextNode
            } else {
                let nextNode = Node(char: char)
                node.children.insert(nextNode)
                node = nextNode
            }
        }
        
        return true 
    }
    
    func contains(_ word: String) -> WordModel? {
        return contains(WordModel(word, locale: locale))
    }
    
    func contains(
        word: String
    ) -> WordModel?
    {
        contains(
            WordModel(word, locale: locale)
        )
    }
    
    func contains(
        _ word: WordModel
    ) -> WordModel? {
        
        guard let result = self.contains(
            word, 
            node: self.root,
            characters: []
        ) else {
            return nil
        }
        
        return result
    }
    
    fileprivate func contains(
        _ word: WordModel, 
        node: BranchNode,
        characters: [CharacterModel]
    ) -> WordModel? 
    {
        let charIx = characters.count
        
        guard charIx < word.count else {
            return WordModel(characters: characters)
        }
        
        guard let char = word.word.optGet(charIx) else { 
            return nil
        }
        
        
        guard let nextNode = node.children.first(where: { $0.char == char }) else {
            return nil
        }
        
        let nextChars = characters + [char]
        
        if let result = contains(
            word, 
            node: nextNode, 
            characters: nextChars) {
            return result 
        }
        
        return nil
    }
}

