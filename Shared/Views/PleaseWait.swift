//
//  PleaseWait.swift
//  MultiplayerWordGame
//
//  Created by Janis Kirsteins on 22/05/2022.
//

import SwiftUI

struct PleaseWait: View {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
            Text(message)
        }
    }
}
