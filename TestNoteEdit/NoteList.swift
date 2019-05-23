//
//  NoteList.swift
//  TestNoteEdit
//
//  Created by Rahul Yadav on 19/05/19.
//  Copyright © 2019 RYTheDev. All rights reserved.
//

import Foundation
import UIKit

class NoteList: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myTableview:UITableView!
    
    
    // MARK ----    tableview callbacks
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return NoteManager.singletonInstance().arrNote.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NoteListCell
        cell.lbl.text = NoteManager.singletonInstance().arrNote[indexPath.row].title
        
        return cell
    }
}

class NoteListCell: UITableViewCell {
    
    @IBOutlet weak var lbl:UILabel!
}
