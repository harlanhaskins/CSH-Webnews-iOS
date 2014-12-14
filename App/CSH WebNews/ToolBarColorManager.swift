//
//  ToolBarColorManager.swift
//  CSH News
//
//  Created by Harlan Haskins on 8/23/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

import UIKit

class ToolBarColorManager: NSObject {
    
    /// Sets the toolbars to a purple background with
    /// white text and tints.
    class func setPurpleToolbars() {
        let barTintColor = UIColor(red: 0.906, green: 0.243, blue: 0.478, alpha: 1.0)
        let tintColor = UIColor(white: 0.98, alpha: 1.0)
        self.setToolBarColors(tintColor: tintColor, barTintColor: barTintColor,
                              textColor: tintColor, lightStatus: true, opaque: true)
    }
    
    /// Sets the toolbars to a green background with
    /// white text and tints.
    class func setGreenToolbars() {
        let barTintColor = UIColor(red: 0.149, green: 0.702, blue: 0.243, alpha: 1.0);
        let tintColor = UIColor(white: 0.98, alpha: 1.0)
        self.setToolBarColors(tintColor: tintColor, barTintColor: barTintColor,
            textColor: tintColor, lightStatus: true, opaque: false)
    }
    
    /// Sets the toolbars to a white background with
    /// black text and blue tints.
    class func setWhiteToolbars() {
        let tintColor = UIColor(red:0.041, green:0.375, blue:0.998, alpha:1.000)
        self.setToolBarColors(tintColor: tintColor, barTintColor: UIColor.whiteColor(), textColor: UIColor.blackColor(), lightStatus: false, opaque: false)
    }
    
    /// Sets the system toolbar colors to what your provide.
    ///
    class func setToolBarColors(#tintColor: UIColor, barTintColor: UIColor, textColor: UIColor, lightStatus: Bool, opaque: Bool) {
        var navBarTitleAttributes = [String : AnyObject]()
        navBarTitleAttributes[NSFontAttributeName] = UIFont(name: "CriqueGrotesk-Bold", size: 18.0)
        navBarTitleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
        
        UINavigationBar.appearance().tintColor = tintColor
        UINavigationBar.appearance().translucent = !opaque;
        
        UINavigationBar.appearance().titleTextAttributes = navBarTitleAttributes
        
        UITabBar.appearance().tintColor = tintColor
        UITabBar.appearance().opaque = opaque;
        
        var tabBarSelectedTitleAttributes = [String : AnyObject]()
        tabBarSelectedTitleAttributes[NSFontAttributeName] = UIFont(name: "CriqueGrotesk-Bold", size: 10.0)
        tabBarSelectedTitleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
        
        UITabBarItem.appearance().setTitleTextAttributes(tabBarSelectedTitleAttributes, forState: .Selected)
        
        var tabBarUnselectedTitleAttributes = [String : AnyObject]()
        tabBarUnselectedTitleAttributes[NSFontAttributeName] = UIFont(name: "CriqueGrotesk", size: 10.0)
        tabBarUnselectedTitleAttributes[NSForegroundColorAttributeName] = UIColor(white: 1.0, alpha: 0.5)
        
        UITabBarItem.appearance().setTitleTextAttributes(tabBarUnselectedTitleAttributes, forState: .Normal)
        UIApplication.sharedApplication().statusBarStyle = lightStatus ? .LightContent : .Default
    }
}
