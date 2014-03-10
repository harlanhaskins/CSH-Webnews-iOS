//
//  ThreadPostsViewController.m
//  CSH News
//
//  Created by Harlan Haskins on 2/5/14.
//  Copyright (c) 2014 Haskins. All rights reserved.
//

#import "ThreadPostsViewController.h"
#import "NewsgroupThread.h"
#import "HHThreadScrollView.h"
#import "HHPostCell.h"
#import "Post.h"
#import "WebNewsDataHandler.h"
#import "NSMutableArray+HHActionButtons.h"

@interface ThreadPostsViewController ()

@property (nonatomic) HHThreadScrollView *scrollView;
@property (nonatomic) NewsgroupThread *thread;
@property (nonatomic) NSInteger postsLoaded;
@property (nonatomic) NSMutableArray *cellActions;

@end

@implementation ThreadPostsViewController

+ (instancetype) controllerWithThread:(NewsgroupThread*)thread {
    ThreadPostsViewController *postsVC = [ThreadPostsViewController new];
    postsVC.thread = thread;
    postsVC.title = thread.post.subject;
    
    postsVC.cellActions = [NSMutableArray array];
    [postsVC.cellActions HH_addActionButtonWithImage:[UIImage imageNamed:@"Reply"]
                                              target:postsVC
                                            selector:@selector(didTapReply)];
    [postsVC.cellActions HH_addActionButtonWithImage:[UIImage imageNamed:@"Star"]
                                              target:postsVC
                                            selector:@selector(didTapStar)];
    
    return postsVC;
}

- (void) didTapReply {
    NSLog(@"Tapped Reply");
}

- (void) didTapStar {
    NSLog(@"Tapped Star");
}

- (void) didTapMarkUnread {
    
}


- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length + 3.0,
                                                    0,
                                                    self.bottomLayoutGuide.length,
                                                    0);
    self.scrollView.frame = self.view.frame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadPosts];
    // Do any additional setup after loading the view.
}

- (void) createScrollView {
    self.scrollView = [HHThreadScrollView threadViewWithPosts:self.thread.allThreads actions:self.cellActions];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentInset =
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
    [self.view addSubview:self.scrollView];
}

- (void) markThreadRead {
    dispatch_async(dispatch_queue_create("Mark Thread Read", 0), ^{
        NSString *parameters = [NSString stringWithFormat:@"mark_read?newsgroup=%@&number=%li&in_thread=true", self.thread.post.newsgroup, (long)self.thread.post.number];
        [WebNewsDataHandler runHTTPPUTOperationWithParameters:parameters success:^(AFHTTPRequestOperation *op, id response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.reloadThreadsBlock();
            });
        } failure:^(AFHTTPRequestOperation *op, NSError *error) {
            NSLog(@"Failed to mark thread read.");
        }];
    });
}

- (NSArray*) posts {
    return self.thread.allPosts;
}

- (void) loadPosts {
    dispatch_async(dispatch_queue_create("Loading Posts", 0), ^{
        for (Post *post in self.posts) {
            [post loadBodyWithBlock:^(Post *currentPost) {
                self.postsLoaded++;
            }];
        }
        while (self.postsLoaded < self.posts.count) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createScrollView];
            [self markThreadRead];
        });
    });
}

@end
