//
//  DiceRollResult.swift
//  DiceRolla
//
//  Created by Marcus Benoit on 11.09.24.
//

import Foundation
import SwiftData

@Model
class PersistentDiceRollResult: Identifiable {
    @Attribute(.unique) var id: UUID
    var value: Int
    var date: Date

    init(value: Int, date: Date = Date()) {
        self.id = UUID()
        self.value = value
        self.date = date
    }
}
