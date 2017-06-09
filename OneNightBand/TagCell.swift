//
//  TagCell.swift
//  TagFlowLayout
//
//  Created by Diep Nguyen Hoang on 7/30/15.
//  Copyright (c) 2015 CodenTrick. All rights reserved.
//

import UIKit



class TagCell: UICollectionViewCell {
    
    
    @IBOutlet weak var tagNameMaxWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tagName: UILabel!
    override func awakeFromNib() {
        self.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        self.tagName.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        self.layer.cornerRadius = 4
        
        
    }
}
