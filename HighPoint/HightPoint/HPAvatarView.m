//
//  HPAvatar.m
//  HighPoint
//
//  Created by Michael on 26.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPAvatarView.h"
#import "UIImage+HighPoint.h"
#import "User.h"
#import "User+UserImage.h"

//==============================================================================
@interface HPAvatarView()
@property (nonatomic, weak) IBOutlet UIView* mainView;
@property (nonatomic, weak) IBOutlet UIImageView* avatar;
@property (nonatomic, weak) IBOutlet UIImageView* avatarBorder;
@end
@implementation HPAvatarView

//==============================================================================

+ (HPAvatarView*) avatarViewWithUser:(User*) user
{
    HPAvatarView* avatarView = [[self alloc] initWithFrame:(CGRect){0,0,88,88}];
    avatarView.user = user;
    return avatarView;
}

//==============================================================================

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void) sharedInit{
    [[NSBundle mainBundle] loadNibNamed: @"HPAvatarView" owner: self options: nil];
    self.mainView.frame = (CGRect){0,0,self.frame.size};
    [self addSubview:self.mainView];

    RAC(self,avatar.image) = [[[[[[RACObserve(self, user) deliverOn:[RACScheduler scheduler]] filter:^BOOL(id value) {
        return value!=nil;
    }] flattenMap:^RACStream *(User *value) {
        return [RACSignal zip:@[[RACSignal return:value.visibility], [value userImageSignal]]];
    }] map:^id(RACTuple *value) {
        RACTupleUnpack(NSNumber *visibility, UIImage *userAvatar) = value;
        switch ((UserVisibilityType) visibility.intValue) {
            case UserVisibilityVisible:
                return userAvatar;
            case UserVisibilityBlur:
            case UserVisibilityHidden:
                return [userAvatar hp_imageWithGaussianBlur:10];
        }
        return nil;
    }] map:^id(UIImage * value) {
        return [value hp_maskImageWithPattern: [UIImage imageNamed: @"Userpic Mask"]];;
    }] deliverOn:[RACScheduler mainThreadScheduler]];

    RAC(self,avatarBorder.image) = [[[RACObserve(self, user.online) deliverOn:[RACScheduler scheduler]] map:^id(NSNumber * online) {
        if(online.boolValue){
            return [UIImage imageNamed: @"Userpic Shape Green"];
        }
        else{
            return [UIImage imageNamed: @"Userpic Shape Red"];
        }
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

@end
