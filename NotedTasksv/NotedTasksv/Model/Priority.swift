//
//  Priority.swift
//  NotedTasks
//
//  Created by Odirile Kekana on 2021/10/04.
//

import Foundation

enum SortTypes: CaseIterable {
    
    case sortByNameAsc
    case sortByNameDesc
    case sortByDateAsc
    case sortByDateDesc
    case color
    
    func getTitleForSortType() -> String {
        var titleString = ""
        switch self {
        case .sortByNameAsc:
            titleString = "Sort By Name (A-Z)"
        case .sortByNameDesc:
            titleString = "Sort By Name (Z-A)"
        case .sortByDateAsc:
            titleString = "Sort By Date (Earliest first)"
        case .sortByDateDesc:
            titleString = "Sort By Date (Latest first)"
        case .color:
            titleString = "Sort by priority"
        }
        return titleString
    }
    
    func getSortDescriptor() -> [NSSortDescriptor] {
        switch self {
        case .sortByNameAsc:
            return [NSSortDescriptor(key: "title", ascending: true)]
        case .sortByNameDesc:
            return [NSSortDescriptor(key: "title", ascending: false)]
        case .sortByDateAsc:
            return [NSSortDescriptor(key: "dueDateTimeStamp", ascending: true)]
        case .sortByDateDesc:
            return [NSSortDescriptor(key: "dueDateTimeStamp", ascending: false)]
        case .color:
            return [NSSortDescriptor(key: "priority", ascending: true)]
        }
    }
    
}
