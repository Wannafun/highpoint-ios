//
//  HPChatMsgTableViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 24.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "HPChatViewController.h"
#import "RACTableViewController.h"


@interface HPChatMsgTableViewCell : UITableViewCell <RACTableViewCellProtocol>


@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITextView * msgTextView;
@property (strong, nonatomic) NSNumber * currentUserId;

- (void) configureSelfWithMsg : (Message *) msg;
- (void) scrollCellForTimeShowingCell :(CGPoint) point;
@end
