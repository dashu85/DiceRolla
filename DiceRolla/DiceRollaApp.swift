//
//  DiceRollaApp.swift
//  DiceRolla
//
//  Created by Marcus Benoit on 11.09.24.
//

import SwiftData
import SwiftUI

@main
struct DiceRollaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [PersistentDiceRollResult.self])
        }
    }
}
