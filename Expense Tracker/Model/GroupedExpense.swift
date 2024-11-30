//
//  GroupedExpense.swift
//  Expense Tracker
//
//  Created by Anubhav Tomar on 29/11/24.
//

import SwiftUI

struct GroupedExpenses: Identifiable {
    var id:UUID = .init()
    var date: Date
    var expenses: [Expense]
    
    var groupTitle: String {
        let calendra = Calendar.current
        
        if calendra.isDateInToday(date){
            return "Today"
        } else if calendra.isDateInYesterday(date){
            return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
}
