//
//  Utilities.swift
//  TestNoteEdit
//
//  Created by Rahul Yadav on 18/05/19.
//  Copyright © 2019 RYTheDev. All rights reserved.
//

import Foundation
import UIKit

class Utility {
    
    static func sizeAsPerScreen(from existingSize:CGFloat) -> CGFloat{
        
        return ((UIScreen.main.bounds.width/320.0) * 0.9) * existingSize
    }
    
    static func apply(overlay:UIView, on:UIView, superView:UIView){
        
        if overlay.superview != superView {
            
            superView.addSubview(overlay)
        }
        overlay.translatesAutoresizingMaskIntoConstraints = false
        
        let leftConstraint = overlay.leadingAnchor.constraint(equalTo: on.safeAreaLayoutGuide.leadingAnchor)
        let btmConstraint = overlay.bottomAnchor.constraint(equalTo: on.safeAreaLayoutGuide.bottomAnchor)
        let rightConstraint = overlay.trailingAnchor.constraint(equalTo: on.safeAreaLayoutGuide.trailingAnchor)
        let topConstraint = overlay.topAnchor.constraint(equalTo: on.safeAreaLayoutGuide.topAnchor)
        NSLayoutConstraint.activate([leftConstraint, btmConstraint, rightConstraint, topConstraint])
    }
}

@IBDesignable
class DesignableLbl:UILabel{
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        font = UIFont(name: font.fontName, size: Utility.sizeAsPerScreen(from: font.pointSize))
    }
}

class KeyboardToolBar: UIView {
    
    @IBOutlet weak var btnDone: UIButton!
    static let nibName = "NoteToolBar"
    
}

//protocol CALayer_additions {
//    
//    
//}
//extension CALayer_additions{
//    
//    
//}



