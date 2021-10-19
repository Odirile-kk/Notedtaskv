//
//  UserNotification.swift
//  NotedTasksv
//
//  Created by Odirile Kekana on 2021/10/18.
//

import Foundation
import UIKit

class UserNotification {
    
    static var shared = UserNotification()

    // Show Alert
    func showAlertMessage(vc: UITableViewController, titleStr:String, messageStr:String) -> Void {
        
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}
