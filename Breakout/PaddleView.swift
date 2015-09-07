//
//  PaddleView.swift
//  Breakout
//
//  Created by Jeroen Schonenberg on 19/05/15.
//  Copyright (c) 2015 private. All rights reserved.
//

import UIKit

class PaddleView: UIView {
    private struct Constants {
        static let backgroundColor = UIColor.whiteColor()
        static let cornerRadius: CGFloat = 2.0
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        setAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func setAppearance (){
        self.backgroundColor = Constants.backgroundColor
        self.layer.cornerRadius = Constants.cornerRadius
    }

}
