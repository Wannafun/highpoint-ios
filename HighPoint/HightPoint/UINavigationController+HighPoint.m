//
//  UINavigationController+HighPoint.m
//  HighPoint
//
//  Created by Michael on 02.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//


#import "UINavigationController+HighPoint.h"
#import "UIDevice+HighPoint.h"



#define ANIMATION_SPEED 0.5



@implementation UINavigationController (HighPoint)



- (void) hp_presentViewController: (UIViewController*) vc
{
    if (vc == nil)
        return;

    CATransition* transition = [self createTransition];
    [self.view.layer addAnimation: transition forKey: nil];
    [self pushViewController: vc animated: NO];
}



- (void) hp_popViewController
{
    CATransition* transition = [self createTransition];
    transition.subtype = kCATransitionFromBottom;
    [self.view.layer addAnimation: transition forKey: nil];
    [self popViewControllerAnimated: NO];
}



- (CATransition*) createTransition
{
    CATransition *transition = [CATransition animation];
    transition.duration = ANIMATION_SPEED;
    transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    
    return transition;
}



- (void) hp_configureNavigationBar {
    UIColor *color = [UIColor colorWithRed:230.0 / 255.0
                                     green:236.0 / 255.0
                                      blue:242.0 / 255.0
                                     alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:30.0 / 255.0 green:29.0 / 255.0 blue:48.0 / 255.0 alpha:1.0]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor: [UIColor clearColor]];
    [shadow setShadowOffset: CGSizeMake(0.0f, 0.0f)];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
            NSForegroundColorAttributeName : color,
            NSShadowAttributeName : shadow,
            NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Book" size:18.0f]
    }];
}



@end
