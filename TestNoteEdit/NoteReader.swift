//
//  ViewController.swift
//  TestNoteEdit
//
//  Created by Rahul Yadav on 18/05/19.
//  Copyright © 2019 RYTheDev. All rights reserved.
//

import UIKit

class NoteReader: UIViewController {
    
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet var commentView: CommentView!
    var noteInfo:NoteInfo!
    var currentHighligtedRange:NSRange?
    var flagInitialDidLayoutSubViews = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialUIConfig()
        initialConfig()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        if flagInitialDidLayoutSubViews{
            
            commentView.imgVwCross.layer.cornerRadius = commentView.imgVwCross.bounds.width/2

            flagInitialDidLayoutSubViews = false
        }
    }
    
    // MARK ----    configurations
    
    private func initialUIConfig(){
        
        txtView.layer.borderColor = UIColor.lightGray.cgColor
        
        commentView.imgVwCross.layer.borderWidth = 1
        commentView.imgVwCross.layer.borderColor = UIColor.black.cgColor
        commentView.txtView.layer.borderColor = UIColor.lightGray.cgColor
        commentView.txtView.tintColor = UIColor.darkGray
        commentView.btnDelete.layer.borderColor = UIColor.lightGray.cgColor
        
//        let editBarBtnItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tappedOnEdit))
//        navigationItem.rightBarButtonItem = editBarBtnItem
    }

    private func initialConfig(){
        
        txtView.attributedText = noteInfo.attrTxt
    }
}

extension NoteReader{
    
    @IBAction func longPressedOnTxtView(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .ended {
            
            let loc = sender.location(in: sender.view)
            let txtPos = txtView.closestPosition(to: loc)
            let sentenceTxtRange = txtView.tokenizer.rangeEnclosingPosition(txtPos!, with: UITextGranularity.sentence, inDirection: UITextDirection(rawValue: UITextLayoutDirection.left.rawValue))
            
            let rangeLoc = txtView.offset(from: txtView.beginningOfDocument, to: sentenceTxtRange!.start)
            let rangeLength = txtView.offset(from: sentenceTxtRange!.start, to: sentenceTxtRange!.end)
            let range = NSMakeRange(rangeLoc, rangeLength)
            
            let mAttrTxt = txtView.attributedText.mutableCopy() as! NSMutableAttributedString
            mAttrTxt.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: range)
            txtView.attributedText = mAttrTxt
            
            noteInfo.attrTxt = mAttrTxt
            
            currentHighligtedRange = range
            
            // Display comment view
            
            Utility.apply(overlay: commentView, on: view, superView: view)
            
            if let existingComment = noteInfo.mDictComment[range]{
                // Case: comment exists
                
                commentView.txtView.text = existingComment
                
                commentView.btnSave.isHidden = true
                commentView.btnDelete.isHidden = false
                commentView.btnUpdate.isHidden = false
            }
            else{
                // Case: comment doesn't exist
                
                commentView.btnSave.isHidden = false
                commentView.btnDelete.isHidden = true
                commentView.btnUpdate.isHidden = true
            }
            commentView.txtView.becomeFirstResponder()
        }
    }
}

// MARK:    ----    touch callbacks
extension NoteReader{
    
    @IBAction func tappedOnDeleteComment(){
        
        let mAttrTxt = NSMutableAttributedString(attributedString: txtView.attributedText)
        mAttrTxt.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.white, range: currentHighligtedRange!)
        txtView.attributedText = mAttrTxt
        
        noteInfo.attrTxt = mAttrTxt
        noteInfo.mDictComment[currentHighligtedRange!] = nil
        NoteManager.singletonInstance().updateNote(noteInfo)
        
        commentView.removeFromSuperview()
    }
    
    @IBAction func tappedOnUpdateComment(){
        
        if commentView.txtView.text.count == 0{
            // Case: no comment
            
            tappedOnDeleteComment()
            
            return
        }
        
        noteInfo.mDictComment[currentHighligtedRange!] = commentView.txtView.text
        NoteManager.singletonInstance().updateNote(noteInfo)
        
        commentView.removeFromSuperview()
    }
    
    @IBAction func tappedOnSaveComment(){
        
        if commentView.txtView.text.count == 0{
            // Case: no comment
            
            let mAttrTxt = NSMutableAttributedString(attributedString: txtView.attributedText)
            mAttrTxt.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.white, range: currentHighligtedRange!)
            txtView.attributedText = mAttrTxt
        }
        else{
            // Case: comment exists
            
            noteInfo.mDictComment[currentHighligtedRange!] = commentView.txtView.text
            NoteManager.singletonInstance().updateNote(noteInfo)
        }
        
        commentView.removeFromSuperview()
    }
    
    @IBAction func tappedOnClose(){
        
        if noteInfo.mDictComment[currentHighligtedRange!] == nil{
            // Case: not an existing comment. Lets undo highlighting
            
            let mAttrTxt = NSMutableAttributedString(attributedString: txtView.attributedText)
            mAttrTxt.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.white, range: currentHighligtedRange!)
            txtView.attributedText = mAttrTxt
            
            currentHighligtedRange = nil
        }
        
        commentView.removeFromSuperview()
    }
    
//    @objc private func tappedOnEdit(){
//
//        txtView.isEditable = true
//        txtView.isSelectable = true
//    }
}

class CommentView: UIView {
    
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var txtView:UITextView!
    @IBOutlet weak var imgVwCross: UIImageView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
}
