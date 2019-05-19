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
    @IBOutlet var commentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialUIConfig()
    }
    
    // MARK ----    configurations
    
    private func initialUIConfig(){
        
        
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
            
            let mAttrTxt = txtView.attributedText.mutableCopy() as! NSMutableAttributedString
            mAttrTxt.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: NSMakeRange(rangeLoc, rangeLength))
            txtView.attributedText = mAttrTxt
            
            Utility.apply(overlay: commentView, on: view, superView: view)
        }
    }
}

class CommentView: UIView {
    
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    
}
