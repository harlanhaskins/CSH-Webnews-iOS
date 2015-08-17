//
//  ThreadCell.swift
//  CSH News
//
//  Created by Harlan Haskins on 8/23/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

import UIKit

private let timeFormatter = TTTTimeIntervalFormatter()
private var memoizedTruncatedStrings = [String : NSAttributedString]()

class ThreadCell: UITableViewCell {
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var unreadCircle: UIView!
    
    var thread: ThreadProtocol?
    var unselectedBackgroundColor: UIColor?
    
    func setThread(thread: ThreadProtocol, indexPath: NSIndexPath) {
        self.thread = thread
        self.postCountLabel.text = "\(thread.numberOfPosts)"
        self.subjectLabel.text = thread.subject
        self.authorLabel.text = thread.author
        let dateString = timeFormatter.stringForTimeIntervalFromDate(NSDate(), toDate: thread.timestamp)
        let detailsAttributedString = NSMutableAttributedString(string: dateString)
        if let newsgroup = thread.newsgroup {
            detailsAttributedString.appendAttributedString(NSAttributedString(string: " to "))
            detailsAttributedString.appendAttributedString(self.truncatedNewsgroupString(newsgroup))
        }
        self.resetUnreadCircle()
        self.pinImageView.hidden = !thread.sticky
        self.detailsLabel.attributedText = detailsAttributedString;
    }
    
    func truncatedNewsgroupString(newsgroup: String) -> NSAttributedString {
        if let truncated = memoizedTruncatedStrings[newsgroup] {
            return truncated
        }
        let stringComponents = newsgroup.componentsSeparatedByString(".")
        let lastString = stringComponents.last!
        let firstChars = stringComponents.map { String(Array($0.characters).first!) }
        let truncatedString = ".".join(firstChars.prefix(firstChars.count - 1)) + "."
        let attributes = [NSForegroundColorAttributeName : UIColor(white: 0.75, alpha: 1.0)]
        
        let truncatedAttributedString = NSMutableAttributedString(string: truncatedString,
                                                              attributes: attributes)
        
        truncatedAttributedString.appendAttributedString(NSAttributedString(string: lastString))
        memoizedTruncatedStrings[newsgroup] = truncatedAttributedString
        return truncatedAttributedString
    }
    
    func resetUnreadCircle() {
        if let color = self.thread?.unreadColor {
            self.unreadCircle.backgroundColor = color
            self.unreadCircle.hidden = false
        } else {
            self.unreadCircle.hidden = true
        }
        self.unreadCircle.layer.cornerRadius = self.unreadCircle.frame.height / 2.0
    }
    
    override func awakeFromNib() {
        self.resetUnreadCircle()
        self.unselectedBackgroundColor = self.contentView.backgroundColor
        timeFormatter.usesIdiomaticDeicticExpressions = true
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let postBackground = self.postCountLabel.backgroundColor!
        if (highlighted) {
            let background = UIColor(white: 0.94, alpha: 1.0)
            self.contentView.backgroundColor = background
            self.accessibilityTraits = UIAccessibilityTraitSelected
        } else {
            UIView.animateWithDuration(0.5, animations: {
                let background = self.unselectedBackgroundColor
                self.contentView.backgroundColor = background
                self.accessibilityTraits = UIAccessibilityTraitNone
            }, completion: nil)
            self.accessibilityTraits = 0
        }
        self.resetUnreadCircle()
        self.postCountLabel.backgroundColor = postBackground
    }
}

@objc protocol ThreadProtocol {
    var subject: String { get }
    var author: String { get }
    var newsgroup: String? { get }
    var timestamp: NSDate { get }
    var numberOfPosts: UInt { get }
    var sticky: Bool { get }
    var unreadColor: UIColor? { get }
}