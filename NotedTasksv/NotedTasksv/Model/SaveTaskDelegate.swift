//
//  SaveTaskDelegate.swift
//  NotedTasks
//
//  Created by Odirile Kekana on 2021/10/01.
//

import Foundation

protocol SaveItem: Any {
    func saveTasks(by controller: DetailTableViewController, title: String, desc: String, priority: String, date: String, at indexPath: NSIndexPath?)
}


