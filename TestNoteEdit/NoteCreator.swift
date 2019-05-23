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
    static let titleMenuItemInsertImage = "Insert Image"
    let basicFont = UIFont.systemFont(ofSize: 17.0)
    let basicTxtColor = UIColor.darkGray
    lazy var insertImageMenuItem:UIMenuItem = {
        
        let menuItemInsertImage = UIMenuItem(title:NoteCreator.titleMenuItemInsertImage, action: #selector(tappedOnInsertImage))
        return menuItemInsertImage
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialUIConfig()
        initialConfig()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        
        
        super.viewWillDisappear(animated)
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
    
    private func initialConfig(){
        
        UIMenuController.shared.menuItems = [insertImageMenuItem]
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
        
        UIMenuController.shared.menuItems = [insertImageMenuItem]
    }
    
    @objc func tappedOnItalic(){
        
        let dictAttr = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: txtView.font!.pointSize)]
        applyMarkdown(dictAttr: dictAttr)
        
        UIMenuController.shared.menuItems = [insertImageMenuItem]
    }
    
    @objc func tappedOnUnderline(){
        
        let dictAttr = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        applyMarkdown(dictAttr: dictAttr)
        
        UIMenuController.shared.menuItems = [insertImageMenuItem]
    }
    
    @objc func tappedOnInsertImage(){
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
//        let updatedTxt = (textView.text! as NSString).replacingCharacters(in: range, with: text)
//        if updatedTxt.count > 0{
//            if txtViewEmpty{
//
//                txtViewEmpty = false
//                handleTxtViewEmptyTransition()
//            }
//        }
        
        return true
    }
    
    /**
     I set the placeholder, text color etc when textview becomes empty or about to have a text
     */
    func handleTxtViewEmptyTransition(){
        
        var txt:String!
        var txtColor:UIColor!
        if txtViewEmpty{
            // Case: showing placeholder
            
            txt = NSLocalizedString(NoteCreator.key_localizable_note_placeHolder, comment: "")
            txtColor = UIColor.lightGray
        }
        else{
            // Case: ready for input from user
            
            txt = "test"    // textview doesn't accept textcolor without text
            txtColor = UIColor.darkGray
        }
        txtView.attributedText = NSAttributedString(string: txt, attributes: [NSAttributedString.Key.foregroundColor : txtColor, .font:UIFont.systemFont(ofSize: 17.0)])
        if txtViewEmpty == false {
            // Case: undoing the dummy text
            
            txtView.attributedText = NSAttributedString(string: "")
        }
    }
}

// MARK ----    handling of image picker
extension NoteCreator: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.originalImage] as? UIImage{
            // Case: user has picked an image
            
            let txtViewTxtRectWidth = txtView.frame.width - (txtView.textContainer.lineFragmentPadding * 2)
            let scaledImage = UIImage(cgImage: pickedImage.cgImage!, scale: (pickedImage.size.width/txtViewTxtRectWidth), orientation: UIImage.Orientation.up)
            
            let attachment = NSTextAttachment()
            attachment.image = scaledImage
            let mAttrStrWithAttachment = NSMutableAttributedString(attachment: attachment)
            mAttrStrWithAttachment.addAttributes([NSAttributedString.Key.font : basicFont, .foregroundColor: basicTxtColor], range: txtView.selectedRange)
            
            let updatedAttrTxt = NSMutableAttributedString(attributedString: txtView.attributedText)
            updatedAttrTxt.replaceCharacters(in: txtView.selectedRange, with: mAttrStrWithAttachment)
            
            txtView.attributedText = updatedAttrTxt
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}

class MarkdownOverlay: UIView {
    
    @IBOutlet weak var btnUnderline: UIButton!
    @IBOutlet weak var btnBold: UIButton!
    @IBOutlet weak var btnItalic: UIButton!
    var startTxtPos:UITextPosition?
    var endTxtPos:UITextPosition?
}
