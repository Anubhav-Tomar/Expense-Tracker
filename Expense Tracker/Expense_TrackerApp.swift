//
//  Expense_TrackerApp.swift
//  Expense Tracker
//
//  Created by Anubhav Tomar on 29/11/24.
//

import SwiftUI

@main
struct Expense_TrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Container setup
        .modelContainer(for: [Expense.self , Category.self])
    }
}
