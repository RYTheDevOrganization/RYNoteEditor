//
//  NoteManager.swift
//  TestNoteEdit
//
//  Created by Rahul Yadav on 23/05/19.
//  Copyright © 2019 RYTheDev. All rights reserved.
//

import Foundation

struct NoteInfo {
    
//    struct Comment:Hashable{
//
//        var txt:String!
//        let range:NSRange!
//    }
    
    let title:String
    var attrTxt:NSAttributedString
    var mDictComment = [NSRange:String]()
    
    init(title:String, attrTxt:NSAttributedString){
        
        self.title = title
        self.attrTxt = attrTxt
    }
//    var comment:String?
//    var commentRange:NSRange?
}

class NoteManager {
    
    var arrNote = [NoteInfo]()
    private static let instance = NoteManager()
    
    static func singletonInstance() -> NoteManager{
        
        return NoteManager.instance
    }
    
    private init(){
    }
    
//    func returnNewNote() -> NoteInfo{
//        
//        let noteInfo = NoteInfo(title: "Note \(ar)", attrTxt: <#T##NSAttributedString#>)
//    }
    
    func addNote(_ attrTxt:NSAttributedString){
        
        let note = NoteInfo(title: "Note \(arrNote.count + 1)", attrTxt: attrTxt)
        
        arrNote.append(note)
    }
    
    func updateNote(_ note:NoteInfo){
        
        let matchedIdx = arrNote.firstIndex { (thisNote:NoteInfo) -> Bool in
            
            return thisNote.title == note.title
        }
        
        arrNote[matchedIdx!] = note
    }
}
