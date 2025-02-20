//
//  HPRoundButton.m
//  HighPoint
//
//  Created by Eugene on 09/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPRoundButton.h"


@implementation HPRoundButton


- (void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius = rect.size.height/2;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:0.f/255.f green:203.f/255.f blue:254.f/255.f alpha:1.f].CGColor;
    self.titleEdgeInsets = UIEdgeInsetsMake(0, 10.f, 0, 10.f);
    self.layer.masksToBounds = YES;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:0.f/255.f green:203.f/255.f blue:254.f/255.f alpha:0.15];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    
}

@end
