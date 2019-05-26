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
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        myTableview.reloadData()
    }
    
    // MARK:    ----    tableview callbacks
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return NoteManager.singletonInstance().arrNote.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NoteListCell
        cell.lbl.text = NoteManager.singletonInstance().arrNote[indexPath.row].title
        
        return cell
    }
    
    // MARK:    ---- segue callbacks
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "reader"{
            
            if let cell = sender as? NoteListCell{
                
                if let indexPath = myTableview.indexPath(for: cell){
                    
                    let noteInfo = NoteManager.singletonInstance().arrNote[indexPath.row]
                    
                    let readerVC = segue.destination as! NoteReader
                    readerVC.noteInfo = noteInfo
                    readerVC.mode = .read
                }
            }
        }
        else if segue.identifier == "create"{
            
            let readerVC = segue.destination as! NoteReader
            readerVC.mode = .create
        }
    }
}

class NoteListCell: UITableViewCell {
    
    @IBOutlet weak var lbl:UILabel!
    @IBOutlet weak var vwSeparator: UIView!
}
