//
//  ViewController.swift
//  TestNoteEdit
//
//  Created by Rahul Yadav on 18/05/19.
//  Copyright © 2019 RYTheDev. All rights reserved.
//

import UIKit

class NoteReader: UIViewController {
    
    enum Mode{
        
        case create, read, edit
    }
    
    var mode:Mode!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet var commentView: CommentView!
    var noteInfo:NoteInfo!
    var currentHighligtedRange:NSRange?
    var flagInitialDidLayoutSubViews = true
    static let titleMenuItemBold = "Bold"
    static let titleMenuItemItalic = "Italic"
    static let titleMenuItemUnderline = "Underline"
    static let titleMenuItemInsertImage = "Insert Image"
    static private let key_localizable_note_placeHolder = "Write anything"
//    var txtViewEmpty = true
    lazy var insertImageMenuItem:UIMenuItem = {
        
        let menuItemInsertImage = UIMenuItem(title:NoteCreator.titleMenuItemInsertImage, action: #selector(tappedOnInsertImage))
        return menuItemInsertImage
    }()
    
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
        
        let keyboardToolBar = Bundle.main.loadNibNamed(KeyboardToolBar.nibName, owner: nil, options: nil)?.first as! KeyboardToolBar
        keyboardToolBar.btnDone.addTarget(self, action: #selector(tappedOnKeyboardDone(sender:)), for: .touchUpInside)
        txtView.inputAccessoryView = keyboardToolBar
        
        txtView.tintColor = UIColor.darkGray
        
        // custom back btn
        configureCustomBackBtn()
    }

    private func initialConfig(){
        
//        if mode == .read{
//
//            txtView.attributedText = noteInfo.attrTxt
//        }
//        else{
//
//            handleTxtViewEmptyTransition()
//        }
        
        configureAsPerMode()
        
        UIMenuController.shared.menuItems = [insertImageMenuItem]
    }
    
    private func configureCustomBackBtn(){
        
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        contentView.backgroundColor = UIColor.clear
        
        // imgVw
        let imgVw = UIImageView(image: UIImage(named: "leftArrow"));
        imgVw.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imgVw)
        NSLayoutConstraint.activate([
            
            imgVw.widthAnchor.constraint(equalToConstant: 25),
            imgVw.heightAnchor.constraint(equalToConstant: 25),
            imgVw.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imgVw.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            
            ])
        
        // Button
        
        let overlayBtn = UIButton()
        Utility.apply(overlay: overlayBtn, on: contentView, superView: contentView)
        overlayBtn.addTarget(self, action: #selector(tappedOnBack), for: UIControl.Event.touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: contentView)
    }
    
    /**
     I configure as per the current mode
    */
    private func configureAsPerMode(){
        
        let txtViewEditable:Bool!
        let title:String!
        
        switch mode! {
            
        case .create:
            
            txtViewEditable = true
//            handleTxtViewEmptyTransition()
          
            title = "Create"
            
        case .read:
            
            txtView.attributedText = noteInfo.attrTxt
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tappedOnEdit))
            txtViewEditable = false
            
            title = "Read"
            
        default:
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tappedOnEditDone))
            txtViewEditable = true
            
            title = "Edit"
        }
        
        txtView.isEditable = txtViewEditable
        txtView.isSelectable = txtViewEditable
        
        self.title = title
    }
    
    // MARK ----    apply markdown
    
    func applyMarkdown(dictAttr:[NSAttributedString.Key:Any]){
        
        let rangeLoc = txtView.offset(from: txtView.beginningOfDocument, to: txtView.selectedTextRange!.start)
        let rangeLength = txtView.offset(from: txtView.selectedTextRange!.start, to: txtView.selectedTextRange!.end)
        
        let mAttrTxt = txtView.attributedText.mutableCopy() as! NSMutableAttributedString
        mAttrTxt.addAttribute(dictAttr.keys.first!, value: dictAttr.values.first!, range: NSMakeRange(rangeLoc, rangeLength))
        txtView.attributedText = mAttrTxt
    }
    
//    /**
//     I set the placeholder, text color etc when textview becomes empty or about to have a text
//     */
//    func handleTxtViewEmptyTransition(){
//
//        var txt:String!
//        var txtColor:UIColor!
//        if txtViewEmpty{
//            // Case: showing placeholder
//
//            txt = NSLocalizedString(NoteReader.key_localizable_note_placeHolder, comment: "")
//            txtColor = UIColor.lightGray
//        }
//        else{
//            // Case: ready for input from user
//
//            txt = "test"    // textview doesn't accept textcolor without text
//            txtColor = UIColor.darkGray
//        }
//        txtView.attributedText = NSAttributedString(string: txt, attributes: [NSAttributedString.Key.foregroundColor : txtColor, .font:UIFont.systemFont(ofSize: 17.0)])
//        if txtViewEmpty == false {
//            // Case: undoing the dummy text
//
//            txtView.attributedText = NSAttributedString(string: "")
//        }
//    }
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
    
    @objc private func tappedOnEdit(){
        
        mode = .edit
        configureAsPerMode()
    }
    
    @objc private func tappedOnEditDone(){

        noteInfo.attrTxt = txtView.attributedText
        
        mode = .read
        configureAsPerMode()
    }
    
    @objc func tappedOnKeyboardDone(sender:UIButton){
        
        txtView.resignFirstResponder()
    }
    
    @objc func tappedOnInsertImage(){
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func tappedOnSave(sender:UIButton){
        
        NoteManager.singletonInstance().addNote(txtView.attributedText)
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
    
    @objc func tappedOnBack(){
        
        if mode == .create{
            if txtView.attributedText.length > 0{
                // Case: create mode
                //      &&
                //      user has written something
                
                NoteManager.singletonInstance().addNote(txtView.attributedText)
            }
        }
        else{
            // Case: read/edit mode
            
            noteInfo.attrTxt = txtView.attributedText
            NoteManager.singletonInstance().updateNote(noteInfo)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: ----    handling of image picker
extension NoteReader: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.originalImage] as? UIImage{
            // Case: user has picked an image
            
            let txtViewTxtRectWidth = txtView.frame.width - (txtView.textContainer.lineFragmentPadding * 2)
            let scaledImage = UIImage(cgImage: pickedImage.cgImage!, scale: (pickedImage.size.width/txtViewTxtRectWidth), orientation: UIImage.Orientation.up)
            
            let attachment = NSTextAttachment()
            attachment.image = scaledImage
            let mAttrStrWithAttachment = NSMutableAttributedString(attachment: attachment)
            
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

// MARK:    ----    textview callbacks
extension NoteReader: UITextViewDelegate{

//    func textViewDidBeginEditing(_ textView: UITextView) {
//
//        if txtViewEmpty {
//
//            txtViewEmpty = false
//            handleTxtViewEmptyTransition()
//        }
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//
//        if textView.text.count == 0{
//
//            txtViewEmpty = true
//            handleTxtViewEmptyTransition()
//        }
//    }
    
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
        
        if mode == .edit{
            
            let affectedRanges = noteInfo.mDictComment.keys.filter { (commentRange:NSRange) -> Bool in
                
                return NSIntersectionRange(commentRange, range).length > 0 ? true : false
            }
            
            for affectedRange in affectedRanges{
                // Case: edit is being done inside commented range. We will remove the comment.
                
                noteInfo.mDictComment[affectedRange] = nil
                
                let mAttrTxt = NSMutableAttributedString(attributedString: txtView.attributedText)
                mAttrTxt.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.white, range: affectedRange)
                txtView.attributedText = mAttrTxt
            }
        }
        
        return true
    }
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
