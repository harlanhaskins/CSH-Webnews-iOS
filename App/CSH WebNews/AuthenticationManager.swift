//
//  AuthenticationManager.swift
//  CSH News
//
//  Created by Harlan Haskins on 8/24/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

import UIKit

private let NullAPIKey = "NULL_API_KEY"
private let APIKey = "api_key"

class AuthenticationManager: NSObject {
    
    class var apiKey: String {
        get {
            return PDKeychainBindings.sharedKeychainBindings().objectForKey(APIKey) as? String ?? NullAPIKey
        }
        set {
            PDKeychainBindings.sharedKeychainBindings().setObject(newValue, forKey: APIKey)
        }
    }
    
    class func invalidateKey() {
        self.apiKey = NullAPIKey
    }
    
    class func keyIsValid() -> Bool {
        return self.apiKey != NullAPIKey
    }
    
}
