//
//  ExpenseView.swift
//  Expense Tracker
//
//  Created by Anubhav Tomar on 29/11/24.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    
    @Binding var currentTab: String
    
    @Query(sort: [
        SortDescriptor(\Expense.date, order: .reverse)
    ], animation: .snappy) private var allExpenses: [Expense]
    
    @State private var groupedExpenses: [GroupedExpenses] = []
    @State private var originalGroupedExpenses: [GroupedExpenses] = [] // Filtering purpose

    @State private var addexpense: Bool = false
    @Environment(\.modelContext) private var context
    
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($groupedExpenses) { $group in
                    Section(group.groupTitle) {
                        ForEach(group.expenses) { expense in
                            ExpenseCardView(expense: expense)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button {
                                        context.delete(expense)
                                        withAnimation {
                                            group.expenses.removeAll(where: { $0.id == expense.id })
                                            
                                            if group.expenses.isEmpty {
                                                groupedExpenses.removeAll(where: { $0.id == group.id })
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search Expenses")
            .overlay {
                if allExpenses.isEmpty || groupedExpenses.isEmpty {
                    ContentUnavailableView {
                        Label("No Expenses Found", systemImage: "tray")
                    }
                }
            }
            
            // New category add button
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addexpense.toggle()
                    }   label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .onChange(of: searchText, initial: false) { oldValue, newValue in
            if !newValue.isEmpty {
                filterExpenses(newValue)
            } else {
                groupedExpenses = originalGroupedExpenses
            }
        }
        .onChange(of: allExpenses, initial: true) { oldValue, newValue in
            if newValue.count > oldValue.count || groupedExpenses.isEmpty || currentTab == "Categories" {
                createGroupedExpenses(newValue)
            }
        }
        .sheet(isPresented: $addexpense) {
            AddExpenseView()
                .interactiveDismissDisabled()
        }
    }
    
    // Filtering expenses
    func filterExpenses(_ text: String) {
        Task.detached(priority: .high) {
            let query = text.lowercased()
            let filteredExpenses = await originalGroupedExpenses.compactMap { group -> GroupedExpenses? in
                let expenses = group.expenses.filter( { $0.title.lowercased().contains(query) } )
                if expenses.isEmpty {
                    return nil
                }
                return .init(date: group.date, expenses: expenses)
            }
            
            await MainActor.run {
                groupedExpenses = filteredExpenses
            }
        }
    }
    
    // Creating Grouped expenses(By Date)
    func createGroupedExpenses(_ expenses: [Expense]) {
        Task.detached(priority: .high) {
            let groupedDict = Dictionary(grouping: expenses) { expene in
                let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: expene.date)
                return dateComponents
            }
            
            // Sorting Dictionary in Descending Order
            let sortedDict = groupedDict.sorted {
                let calendra = Calendar.current
                let date1 = calendra.date(from: $0.key) ?? .init()
                let date2 = calendra.date(from: $1.key) ?? .init()
                
                return calendra.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
            }
            
            // Adding to the grouped expenses array
            await MainActor.run {
                groupedExpenses = sortedDict.compactMap({ dict in
                    let date = Calendar.current.date(from: dict.key) ?? .init()
                    return .init(date: date, expenses: dict.value)
                })
                originalGroupedExpenses = groupedExpenses
            }
        }
    }
}
//
//#Preview {
//    ExpensesView()
//}
