//
//  EmptyTableViewFormatter.swift
//  CSH News
//
//  Created by Harlan Haskins on 10/21/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

import UIKit

private let NoPostsLabel = UILabel()

extension UITableView {
    func addLoadingTextIfNecessaryForRows(rows: UInt, withItemName name: String) {
        if (rows == 0) {
            NoPostsLabel.text = "Loading \(name)..."
            NoPostsLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            NoPostsLabel.textColor = UIColor.lightGrayColor()
            NoPostsLabel.textAlignment = .Center
            NoPostsLabel.sizeToFit();
            self.backgroundView = NoPostsLabel;
            self.separatorStyle = .None;
        }
        else {
            self.backgroundView = nil;
            self.separatorStyle = .SingleLine;
        }
    }
}
