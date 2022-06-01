//
//  TurnManager.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 01/06/2022.
//

import Foundation

protocol TurnManager {
    var isLocal: Bool { get }
}

class TurnManagerWrapper: TurnManager, ObservableObject {
    let wrapped: TurnManager
    
    var isLocal: Bool { wrapped.isLocal }
    
    init(_ wrapped: TurnManager) {
        self.wrapped = wrapped
    }
}

class LocalTurnManager: TurnManager {
    let isLocal = true
}

class GameKitTurnManager: TurnManager {
    let isLocal = false
}
