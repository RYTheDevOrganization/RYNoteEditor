//
//  NoteCreator.swift
//  TestNoteEdit
//
//  Created by Rahul Yadav on 19/05/19.
//  Copyright © 2019 RYTheDev. All rights reserved.
//

import Foundation
import UIKit

class NoteCreator: UIViewController {
    
    @IBOutlet weak var txtView: UITextView!
    static private let key_localizable_note_placeHolder = "Write anything"
    var txtViewEmpty = true
    @IBOutlet var editOverlay: MarkdownOverlay!
    static let titleMenuItemBold = "Bold"
    static let titleMenuItemItalic = "Italic"
    static let titleMenuItemUnderline = "Underline"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialUIConfig()
    }
    
    // MARK ----    configurations
    
    private func initialUIConfig(){
        
        handleTxtViewEmptyTransition()
        
        let keyboardToolBar = Bundle.main.loadNibNamed(KeyboardToolBar.nibName, owner: nil, options: nil)?.first as! KeyboardToolBar
        keyboardToolBar.btnDone.addTarget(self, action: #selector(tappedOnKeyboardDone(sender:)), for: .touchUpInside)
        txtView.inputAccessoryView = keyboardToolBar
        
        txtView.layer.borderColor = UIColor.lightGray.cgColor
        txtView.tintColor = UIColor.darkGray
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Markdown", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tappedOnEditBtn(sender:)))
    }
    
    // MARK ----    apply markdown
    
    func applyMarkdown(dictAttr:[NSAttributedString.Key:Any]){
        
        let rangeLoc = txtView.offset(from: txtView.beginningOfDocument, to: txtView.selectedTextRange!.start)
        let rangeLength = txtView.offset(from: txtView.selectedTextRange!.start, to: txtView.selectedTextRange!.end)
    
        let mAttrTxt = txtView.attributedText.mutableCopy() as! NSMutableAttributedString
        mAttrTxt.addAttribute(dictAttr.keys.first!, value: dictAttr.values.first!, range: NSMakeRange(rangeLoc, rangeLength))
        txtView.attributedText = mAttrTxt
    }
}

extension NoteCreator{
    
    @objc func tappedOnKeyboardDone(sender:UIButton){
        
        txtView.resignFirstResponder()
    }
    
    @objc func tappedOnEditBtn(sender:UIButton){
     
        txtView.resignFirstResponder()
        
        Utility.apply(overlay: editOverlay, on: navigationController!.view, superView: navigationController!.view)
    }
    
    @IBAction func tappedOnOverlayDone(sender:UIButton){
        
        editOverlay.btnBold.isEnabled = false
        editOverlay.btnItalic.isEnabled = false
        editOverlay.btnUnderline.isEnabled = false

        editOverlay.removeFromSuperview()
    }
    
    @IBAction func panningOnOverlay(sender:UIPanGestureRecognizer){

        func highlightSelectedTxt(tillPos:UITextPosition){
            
            let rangeLoc = txtView.offset(from: txtView.beginningOfDocument, to: editOverlay.startTxtPos!)
            let rangeLength = txtView.offset(from: editOverlay.startTxtPos!, to: tillPos)
            
            let mAttrTxt = txtView.attributedText.mutableCopy() as! NSMutableAttributedString
            mAttrTxt.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: NSMakeRange(rangeLoc, rangeLength))
            txtView.attributedText = mAttrTxt
        }
        
        if sender.state == .began{
            
            let loc = sender.location(in: sender.view)
            editOverlay.startTxtPos = txtView.closestPosition(to: loc)
        }
        else if sender.state == .changed || sender.state == .ended{
            
            let loc = sender.location(in: sender.view)
            if let txtPos = txtView.closestPosition(to: loc){
                
                highlightSelectedTxt(tillPos: txtPos)
                editOverlay.endTxtPos = txtPos
            }
            
            if sender.state == .ended{
                if editOverlay.startTxtPos != nil && editOverlay.endTxtPos != nil{
                    
                    editOverlay.btnBold.isEnabled = true
                    editOverlay.btnItalic.isEnabled = true
                    editOverlay.btnUnderline.isEnabled = true
                }
            }
        }
        
        if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
            
            editOverlay.startTxtPos = nil
            editOverlay.endTxtPos = nil
        }
    }
    
    @objc func tappedOnBold(){
        
        let dictAttr = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: txtView.font!.pointSize)]
        applyMarkdown(dictAttr: dictAttr)
        
        UIMenuController.shared.menuItems = nil
    }
    
    @objc func tappedOnItalic(){
        
        let dictAttr = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: txtView.font!.pointSize)]
        applyMarkdown(dictAttr: dictAttr)
        
        UIMenuController.shared.menuItems = nil
    }
    
    @objc func tappedOnUnderline(){
        
        let dictAttr = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        applyMarkdown(dictAttr: dictAttr)
        
        UIMenuController.shared.menuItems = nil
    }
}

extension NoteCreator: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if txtViewEmpty {
            
            txtViewEmpty = false
            handleTxtViewEmptyTransition()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.count == 0{
            
            txtViewEmpty = true
            handleTxtViewEmptyTransition()
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        textView.resignFirstResponder()
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        if txtView.selectedTextRange != nil{
            if let selectedTxt = txtView.text(in: textView.selectedTextRange!){
                if selectedTxt.count > 0{
                    
                    let menuItemBold = UIMenuItem(title:NoteCreator.titleMenuItemBold, action: #selector(tappedOnBold))
                    let menuItemItalic = UIMenuItem(title:NoteCreator.titleMenuItemItalic, action: #selector(tappedOnItalic))
                    let menuItemUnderline = UIMenuItem(title:NoteCreator.titleMenuItemUnderline, action: #selector(tappedOnUnderline))

                    UIMenuController.shared.menuItems = [menuItemBold, menuItemItalic, menuItemUnderline]
                }
            }
        }
    }
    
    /**
     I set the placeholder, text color etc when textview becomes empty or about to have a text
     */
    func handleTxtViewEmptyTransition(){
        
        var txt:String!
        var txtColor:UIColor!
        if txtViewEmpty{
            
            txt = NSLocalizedString(NoteCreator.key_localizable_note_placeHolder, comment: "")
            txtColor = UIColor.lightGray
        }
        else{
            
            txt = ""
            txtColor = UIColor.darkGray
        }
        txtView.attributedText = NSAttributedString(string: txt, attributes: [NSAttributedString.Key.foregroundColor : txtColor, .font:UIFont.systemFont(ofSize: 17.0)])
    }
}

class MarkdownOverlay: UIView {
    
    @IBOutlet weak var btnUnderline: UIButton!
    @IBOutlet weak var btnBold: UIButton!
    @IBOutlet weak var btnItalic: UIButton!
    var startTxtPos:UITextPosition?
    var endTxtPos:UITextPosition?
}
