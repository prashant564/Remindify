//
//  ReminderListStyle.swift
//  Remindify
//
//  Created by PrashantDixit on 05/07/23.
//

import Foundation

enum ReminderListStyle: Int {
    case today
    case future
    case all
    
    func shouldInclude(date: Date) -> Bool {
        let isInToday = Locale.current.calendar.isDateInToday(date)
        switch self {
        case .today:
            return isInToday
        case .future:
            return (date > Date.now) && !isInToday
        case .all:
            return true
        }
    }
    
    var name: String {
        switch self {
        case .today: return NSLocalizedString("Today", comment: "Today Style Name")
        case .future: return NSLocalizedString("Future", comment: "Future Style Name")
        case .all: return NSLocalizedString("All", comment: "All Style Name")
        }
    }
}
