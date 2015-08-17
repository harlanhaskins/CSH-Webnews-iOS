//
//  UILabel+AutoWidth.m
//  Bryx 911
//
//  Created by Harlan Haskins on 12/27/14.
//  Copyright (c) 2014 Bryx. All rights reserved.
//


extension UILabel {
    public override class func initialize() {
        struct Static {
            static var onceToken = dispatch_once_t()
        }
        dispatch_once(&Static.onceToken) {
            self.swizzleSelector("setBounds:", withSelector: "auto_setBounds:")
            self.swizzleSelector("updateConstraints", withSelector: "auto_updateConstraints")
        }
    }
    
    func auto_setBounds(bounds: CGRect) {
        self.auto_setBounds(bounds)
        if self.preferredMaxLayoutWidth != bounds.width {
            self.preferredMaxLayoutWidth = bounds.width
        }
    }
    
    func auto_updateConstraints() {
        if self.preferredMaxLayoutWidth != self.bounds.width {
            self.preferredMaxLayoutWidth = self.bounds.width
        }
        self.auto_updateConstraints()
    }
}