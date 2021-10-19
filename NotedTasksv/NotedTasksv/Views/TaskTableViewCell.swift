//
//  TaskTableViewCell.swift
//  NotedTasks
//
//  Created by Odirile Kekana on 2021/10/01.
//

import UIKit

protocol  TaskTableViewCellDelegate: Any {
    func checkBoxToggle(sender: TaskTableViewCell)
}

class TaskTableViewCell: UITableViewCell {

    var delegate: TaskTableViewCellDelegate?
    
    @IBOutlet weak var taskLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var pickBtn: UIButton!
//    @IBOutlet weak var taskStatus: UIImageView!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var date: UILabel!
    
    @IBAction func checkToggled(_ sender: Any) {
        delegate?.checkBoxToggle(sender: self)
    }
    

}
