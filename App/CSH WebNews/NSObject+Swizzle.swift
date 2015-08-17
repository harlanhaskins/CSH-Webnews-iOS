//
//  NSObject+NSObject_Swizzle.m
//  Bryx 911
//
//  Created by Harlan Haskins on 5/27/15.
//  Copyright (c) 2015 Bryx. All rights reserved.
//

extension NSObject {
    
    class func swizzleSelector(originalSelector: Selector, withSelector swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        let didAddMethod = class_addMethod(self,
            originalSelector,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(self,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
}
