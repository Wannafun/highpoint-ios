//
//  HPCurrentUserPointCollectionViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 05.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserPointCollectionViewCell.h"
#import "UILabel+HighPoint.h"
#import "UIButton+HighPoint.h"
#import "UITextView+HightPoint.h"
#import "UIDevice+HighPoint.h"
#import "UIImage+HighPoint.h"

#define POINT_LENGTH 150
#define CONSTRAINT_AVATAR_TOP 10.0
#define CONSTRAINT_POINT_TOP 180.0
#define CONSTRAINT_POINT_INFO_TOP 274.0
#define CONSTRAINT_BTNS_BOTTOM_TOP 318.0
#define CONSTRAINT_VIEW_BOTTOM_TOP 318.0

@interface HPCurrentUserPointCollectionViewCell()
//Private methods
- (void) editPointUp;
- (void) editPointDown;


//Private properties
@property (weak, nonatomic) IBOutlet UILabel *yourPointLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *pointInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *publishBtn;
@property (weak, nonatomic) IBOutlet UITextView *pointTextView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
//point settings
@property (weak, nonatomic) IBOutlet UIView *pointSettingsView;
@property (weak, nonatomic) IBOutlet HPSlider *pointTimeSlider;
@property (weak, nonatomic) IBOutlet UILabel *pointTimeInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *publishSettBtn;
//point delete
@property (weak, nonatomic) IBOutlet UIView *deletePointView;
@property (weak, nonatomic) IBOutlet UILabel *deletePointInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *deletePointSettBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelDelBtn;
@end

@implementation HPCurrentUserPointCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self fixUserPointConstraint];
    [self.pointSettingsView setHidden:YES];
    [self setImageViewBgTap];
    self.isUp = NO;
    self.yourPointLabel.text = NSLocalizedString(@"YOUR_POINT", nil);
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 5;
    self.avatarImageView.image = [self.avatarImageView.image addBlendToPhoto];
    self.deletePointInfoLabel.text = NSLocalizedString(@"DELETE_POINT_INFO", nil);
    self.pointTextView.delegate = self;
    self.pointTextView.text = NSLocalizedString(@"YOUR_EMPTY_POINT", nil);
    [self.pointTimeSlider setValue:6 animated:YES];
    [self.pointTimeSlider initOnLoad];
    self.pointTimeInfoLabel.text = NSLocalizedString(@"SET_TIME_FOR_YOUR_POINT", nil);
}

- (void) updateConstraints
{
    [super updateConstraints];
}

#pragma mark - text view

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(startEditingPoint)]) {
        [self.delegate startEditingPoint];
    }
    [self editPointUp];
    [self setSymbolsCounter];
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    [self editPointDown];
}

-(void)textViewDidChange:(UITextView *)textView
{
    [self setSymbolsCounter];
}

#pragma mark - symbols counting

- (void) setSymbolsCounter {
    
    signed int symbCount = POINT_LENGTH - self.pointTextView.text.length;
    self.pointInfoLabel.text = [NSString stringWithFormat:@"%d", symbCount];
    if(symbCount <=10) {
        [self.pointInfoLabel hp_tuneForSymbolCounterRed];
    } else {
        [self.pointInfoLabel hp_tuneForSymbolCounterWhite];
    }
}


#pragma mark - constraint
- (void) fixUserPointConstraint
{
    if (![UIDevice hp_isWideScreen])
    {
        NSArray* cons = self.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.avatarImageView))
                consIter.constant = CONSTRAINT_AVATAR_TOP;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.pointTextView))
                consIter.constant = CONSTRAINT_POINT_TOP;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.pointInfoLabel))
                consIter.constant = CONSTRAINT_POINT_INFO_TOP;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.publishBtn))
                consIter.constant = CONSTRAINT_BTNS_BOTTOM_TOP;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.deleteBtn))
                consIter.constant = CONSTRAINT_BTNS_BOTTOM_TOP;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.deletePointView))
                consIter.constant = CONSTRAINT_VIEW_BOTTOM_TOP;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.pointSettingsView))
                consIter.constant = CONSTRAINT_VIEW_BOTTOM_TOP;
        }
    }
}



#pragma mark - animation
- (void) editPointUp {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y - 115, weakSelf.frame.size.width, weakSelf.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         weakSelf.isUp = YES;
                     }];
}

- (void) editPointDown {
    __weak typeof(self) weakSelf = self;
    if (self.isUp) {
        [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y + 115, weakSelf.frame.size.width, weakSelf.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             weakSelf.isUp = NO;
                         }];
    }
}


#pragma mark - tap

-(void) setImageViewBgTap {
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(bgTap)];
    tgr.delegate = self;
    [self.avatarImageView addGestureRecognizer:tgr];
}

- (void) bgTap {
    if ([self.delegate respondsToSelector:@selector(cancelPointTap)]) {
        [self.delegate cancelPointTap];
    }
}

- (IBAction)publishSettTap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sharePointTap)]) {
        [self.delegate sharePointTap];
    }
}


- (IBAction)deletePointTap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(startDeletePoint)]) {
        [self.delegate startDeletePoint];
    }
    [self editPointUp];
    self.pointTextView.userInteractionEnabled = NO;
    self.avatarImageView.userInteractionEnabled = NO;
    self.publishBtn.hidden = YES;
    self.deleteBtn.hidden = YES;
    self.pointSettingsView.hidden = YES;
    self.deletePointView.hidden = NO;
}

- (IBAction)deleteSettTap:(id)sender {
    [self editPointDown];
    self.pointTextView.userInteractionEnabled = YES;
    self.avatarImageView.userInteractionEnabled = YES;
    self.deletePointView.hidden = YES;
    self.publishBtn.hidden = NO;
    self.deleteBtn.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(endDeletePoint)]) {
        [self.delegate endDeletePoint];
    }
}

- (IBAction)cancelSettTap:(id)sender {
    [self editPointDown];
    self.pointTextView.userInteractionEnabled = NO;
    self.avatarImageView.userInteractionEnabled = NO;
    self.deletePointView.hidden = YES;
    self.publishBtn.hidden = YES;
    self.deleteBtn.hidden = NO;
    if ([self.delegate respondsToSelector:@selector(endDeletePoint)]) {
        [self.delegate endDeletePoint];
    }
}

@end
