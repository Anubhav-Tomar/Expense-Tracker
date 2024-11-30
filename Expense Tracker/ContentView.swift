//
//  ContentView.swift
//  Expense Tracker
//
//  Created by Anubhav Tomar on 29/11/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var currentTab: String = "Expenses"
    
    var body: some View {
        TabView(selection: $currentTab) {
            ExpensesView(currentTab: $currentTab)
                .tag("Expenses")
                .tabItem {
                    Image(systemName: "creditcard")
                        .environment(\.symbolVariants, .none)
                    Text("Expenses")
                }
            
            CategoriesView()
                .tag("Categories")
                .tabItem {
                    Image(systemName: "list.clipboard")
                        .environment(\.symbolVariants, .none)
                    Text("Categories")
                }
        }
    }
}

#Preview {
    ContentView()
}
