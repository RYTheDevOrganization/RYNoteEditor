//
//  NoteManager.swift
//  TestNoteEdit
//
//  Created by Rahul Yadav on 23/05/19.
//  Copyright © 2019 RYTheDev. All rights reserved.
//

import Foundation

struct NoteInfo {
    
    let title:String
    var attrTxt:NSAttributedString
    var comment:String?
}

struct NoteManager {
    
    var arrNote = [NoteInfo]()
    
    static func singletonInstance() -> NoteManager{
        
        return NoteManager()
    }
    
    private init(){
    }
    
    mutating func addNote(_ note:NoteInfo){
        
        arrNote.append(note)
    }
    
    mutating func updateNote(_ note:NoteInfo){
        
        let matchedIdx = arrNote.firstIndex { (thisNote:NoteInfo) -> Bool in
            
            return thisNote.title == note.title
        }
        
        arrNote[matchedIdx!] = note
    }
}
