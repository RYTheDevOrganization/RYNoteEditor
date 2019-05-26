//
//  NoteList.swift
//  TestNoteEdit
//
//  Created by Rahul Yadav on 19/05/19.
//  Copyright © 2019 RYTheDev. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NoteList: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myTableview:UITableView!
    lazy var coredataFetchResultC: NSFetchedResultsController<Note> = {
       
        let req = NSFetchRequest<Note>(entityName: "Note")
        let sortDes = NSSortDescriptor(key: "updatedOn", ascending: false)
        req.sortDescriptors = [sortDes]
        
        let cdFetchResultC = NSFetchedResultsController<Note>(fetchRequest: req, managedObjectContext: AppDelegate.instance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        cdFetchResultC.delegate = self
        return cdFetchResultC
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        try? coredataFetchResultC.performFetch()
        
//        myTableview.reloadData()
    }
    
    // MARK:    ----    tableview callbacks
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let fetchedObjs = coredataFetchResultC.fetchedObjects{
            
            return fetchedObjs.count
        }
        return 0//NoteManager.singletonInstance().arrNote.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NoteListCell
//        cell.lbl.text = NoteManager.singletonInstance().arrNote[indexPath.row].title
        
        if let fetchedObjs = coredataFetchResultC.fetchedObjects{
            
            let note = fetchedObjs[indexPath.row]
            cell.lbl.text = note.title
        }
        
        return cell
    }
    
    // MARK:    ---- segue callbacks
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "reader"{
            
            if let cell = sender as? NoteListCell{
                
                if let indexPath = myTableview.indexPath(for: cell){
                    
//                    let noteInfo = NoteManager.singletonInstance().arrNote[indexPath.row]
                    
                    let noteInfo = coredataFetchResultC.fetchedObjects![indexPath.row]
                    
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

// MARK:    ----    core data
extension NoteList: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        myTableview.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            myTableview.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            myTableview.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            myTableview.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            myTableview.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        myTableview.endUpdates()
    }
}

class NoteListCell: UITableViewCell {
    
    @IBOutlet weak var lbl:UILabel!
    @IBOutlet weak var vwSeparator: UIView!
}
