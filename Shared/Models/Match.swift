//
//  Match.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 23/05/2022.
//

import SwiftUI
import GameKit

enum MatchState: Codable {
    case uninitialized
}

struct MatchData: Hashable, Equatable, Codable, Identifiable {
    let id: String
    
    static func loadData(_ data: Data) throws -> MatchData {
        guard data.count > 0 else {
            return MatchData()
        }
        
        let j = JSONDecoder()
        return try j.decode(MatchData.self, from: data)
    }
    
    init() {
        self.id = UUID().uuidString
    }
    
    init(_ data: NSData) throws {
        self = try Self.loadData(data as Data)
    }
    
    init(_ data: Data) throws {
        self = try Self.loadData(data)
    }
}

public struct LocalMatch: Hashable, Equatable, Identifiable, Codable {
    let data: MatchData
    
    public var id: String {
        data.id
    }
}

enum Match: Identifiable {
   
    case none   // uninitialized
    
    /// Local match
    case local(LocalMatch)
    /// Match that may be fully or partialy loaded
    case online(GKTurnBasedMatch, MatchData?)
    
    var data: MatchData? {
        switch(self) {
        case .none:
            fatalError("Do not use .none")
        case .local(let m):
            return m.data
        case .online(_, let data):
            return data
        }
    }
    
    var id: String {
        switch(self) {
        case .none:
            fatalError("Do not use .none")
        case .local(let match):
            return match.id
        case .online(let match, _):
            return match.matchID
        }
    }
}
