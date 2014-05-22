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
#import "Post.h"
#import "WebNewsDataHandler.h"
#import "NSMutableArray+HHActionButtons.h"
#import "NewPostViewController.h"
#import "HHPostCell.h"
#import "HHPostCellActionsView.h"
#import "SVProgressHUD.h"

@interface ThreadPostsViewController () <NewsgroupThreadDelegate>

@property (nonatomic) HHThreadScrollView *scrollView;
@property (nonatomic) NewsgroupThread *thread;
@property (nonatomic) NSInteger postsLoaded;

@end

@implementation ThreadPostsViewController

+ (instancetype) controllerWithThread:(NewsgroupThread*)thread {
    ThreadPostsViewController *postsVC = [ThreadPostsViewController new];
    postsVC.thread = thread;
    return postsVC;
}

- (void) setThread:(NewsgroupThread *)thread {
    _thread = thread;
    for (NewsgroupThread *child in thread.allThreads) {
        child.delegate = self;
    }
    self.title = thread.post.subject;
}

- (void) didTapReply:(UIButton*)sender {
    NewsgroupThread *threadToReply = self.thread.allThreads[sender.tag];
    [self replyToPost:threadToReply];
}

- (void) didTapStar:(UIButton*)sender {
    NewsgroupThread *threadToStar = self.thread.allThreads[sender.tag];
    NSString *url = [NSString stringWithFormat:@"%@/%li/star", threadToStar.board, (long)threadToStar.number];
    [[WebNewsDataHandler sharedHandler] PUT:url parameters:nil success:^(NSURLSessionDataTask *task, id response) {
        BOOL starred = [response[@"starred"] boolValue];
        if (starred) {
            [sender setImage:[UIImage imageNamed:@"StarFilled"] forState:UIControlStateNormal];
        }
        else {
            [sender setImage:[UIImage imageNamed:@"Star"] forState:UIControlStateNormal];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
    }];
}

- (void) didTapDelete:(UIButton*)sender {
    NewsgroupThread *threadToDelete = self.thread.allThreads[sender.tag];
    NSString *url = [NSString stringWithFormat:@"%@/%li", threadToDelete.board, (long)threadToDelete.number];
    NSDictionary *parameters = @{@"confirm_cancel" : @YES};
    [[WebNewsDataHandler sharedHandler] DELETE:url parameters:parameters success:^(NSURLSessionDataTask *task, id response) {
        [self reloadThread];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
    }];
}

- (void) reloadThread {
    NewsgroupThread *thread = self.thread;
    NSString *url = [NSString stringWithFormat:@"%@/%li", thread.board, (long)thread.number];
    [[WebNewsDataHandler sharedHandler] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id response) {
        self.thread = [NewsgroupThread newsgroupThreadWithDictionary:response];
        [self loadPosts];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
    }];
}

- (void) replyToPost:(id<HHPostProtocol>)post {
    NewPostViewController *replyVC = [NewPostViewController replyControllerWithPost:post];
    replyVC.didSendReplyBlock = ^ {
        self.reloadThreadsBlock();
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:replyVC]
                       animated:YES
                     completion:nil];
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
    if (self.scrollView) {
        [self.scrollView removeFromSuperview];
        self.scrollView = nil;
    }
    self.scrollView = [HHThreadScrollView threadViewWithPosts:self.thread.allThreads];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentInset =
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
    [self.view addSubview:self.scrollView];
}

- (void) markThreadRead {
    dispatch_async(dispatch_queue_create("Mark Thread Read", NULL), ^{
        
        NSDictionary *parameters = @{@"newsgroup" : self.thread.post.newsgroup,
                                     @"number" : @(self.thread.post.number),
                                     @"in_thread" : @"true"};
        
        [[WebNewsDataHandler sharedHandler] PUT:@"mark_read" parameters:parameters success:^(NSURLSessionDataTask *task, id response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.reloadThreadsBlock) {
                    self.reloadThreadsBlock();
                }
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"%s [Line: %d] %@", __PRETTY_FUNCTION__, __LINE__, error);
        }];
    });
}

- (NSArray*) posts {
    return self.thread.allPosts;
}

- (void) loadPosts {
    [SVProgressHUD showWithStatus:@"Loading posts."];
    dispatch_async(dispatch_queue_create("Loading Posts", NULL), ^{
        for (Post *post in self.posts) {
            [post loadBodyWithBlock:^(Post *currentPost) {
                self.postsLoaded++;
            }];
        }
        while (self.postsLoaded < self.posts.count) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self createScrollView];
            [self markThreadRead];
        });
    });
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return self.supportedInterfaceOrientations;
}

@end
