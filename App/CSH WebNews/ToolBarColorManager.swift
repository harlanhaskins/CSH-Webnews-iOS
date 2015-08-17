//
//  ToolBarColorManager.swift
//  CSH News
//
//  Created by Harlan Haskins on 8/23/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

import UIKit

extension UIApplication {
    
    /// Sets the toolbars to a purple background with
    /// white text and tints.
    func setPurpleToolbars() {
        let barTintColor = UIColor(red: 231/255, green: 62/255, blue: 122/255, alpha: 1.0)
        let tintColor = UIColor(white: 0.98, alpha: 1.0)
        var navBarTitleAttributes = [String : AnyObject]()
        navBarTitleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
        
        UINavigationBar.appearance().tintColor = tintColor
        UINavigationBar.appearance().barTintColor = barTintColor
        UINavigationBar.appearance().translucent = false
        
        UIToolbar.appearance().tintColor = tintColor
        UIToolbar.appearance().barTintColor = barTintColor
        UIToolbar.appearance().translucent = false
        
        UINavigationBar.appearance().titleTextAttributes = navBarTitleAttributes
        UINavigationBar.appearance().barStyle = .BlackTranslucent
        UITabBar.appearance().tintColor = tintColor
        UITabBar.appearance().barTintColor = barTintColor
        UITabBar.appearance().translucent = false
        
        var tabBarSelectedTitleAttributes = [String : AnyObject]()
        tabBarSelectedTitleAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
        
        UITabBarItem.appearance().setTitleTextAttributes(tabBarSelectedTitleAttributes, forState: .Selected)
        
        var tabBarUnselectedTitleAttributes = [String : AnyObject]()
        tabBarUnselectedTitleAttributes[NSForegroundColorAttributeName] = UIColor(white: 1.0, alpha: 0.5)
        
        UITabBarItem.appearance().setTitleTextAttributes(tabBarUnselectedTitleAttributes, forState: .Normal)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
}
