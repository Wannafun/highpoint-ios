//
//  HPUserCardViewController.m
//  HightPoint
//
//  Created by Andrey Anisimov on 13.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserCardViewController.h"
#import "Utils.h"
#import "UIImage+HighPoint.h"
#import "UINavigationController+HighPoint.h"
#import "UIViewController+HighPoint.h"
#import "UILabel+HighPoint.h"
#import "UIView+HighPoint.h"
#import "HPUserCardView.h"
#import "HPUserCardOrPointView.h"
#import "UIDevice+HighPoint.h"
#import "DataStorage.h"
#import "User.h"

#import "HPBaseNetworkManager.h"
#import "NotificationsConstants.h"
#import "ModalAnimation.h"
//==============================================================================

#define ICAROUSEL_ITEMS_COUNT 50
#define ICAROUSEL_ITEMS_WIDTH 264.0
#define GREENBUTTON_BOTTOM_SHIFT 50
#define SPACE_BETWEEN_GREENBUTTON_AND_INFO 40
#define FLIP_ANIMATION_SPEED 0.5
#define CONSTRAINT_TOP_FOR_CAROUSEL 76
#define CONSTRAINT_WIDE_TOP_FOR_CAROUSEL 80
#define CONSTRAINT_HEIGHT_FOR_CAROUSEL 340

//==============================================================================

@implementation HPUserCardViewController

//==============================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initObjects];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.onlyWithPoints) {
        usersArr = [[[DataStorage sharedDataStorage] allUsersWithPointFetchResultsController] fetchedObjects];
    } else {
        usersArr = [[[DataStorage sharedDataStorage] allUsersFetchResultsController] fetchedObjects];
    }
    [_carouselView reloadData];
    [_carouselView scrollToItemAtIndex:self.current animated:NO];
    [self registerNotification];
    self.navigationItem.title = [Utils getTitleStringForUserFilter];
    _modalAnimationController = [[ModalAnimation alloc] init];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotification];
}


#pragma mark - Transitioning Delegate (Modal)
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _modalAnimationController.type = AnimationTypePresent;
    return _modalAnimationController;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _modalAnimationController.type = AnimationTypeDismiss;
    return _modalAnimationController;
}
- (void)profileWillBeHidden {
    [self animationViewsDown];
}
- (void) animationViewsUp {
    UIImage *captureImg = [Utils captureView:self.carouselView.currentItemView withArea:CGRectMake(0, 0, self.carouselView.currentItemView.frame.size.width, self.carouselView.currentItemView.frame.size.height)];
    
    //need get cell from left and right
    UIView* leftView;
    UIView* rightView;
    
    NSLog(@"%d",self.carouselView.currentItemIndex);
    NSLog(@"%d",self.carouselView.numberOfItems);
    
    if(self.carouselView.currentItemIndex > 0 && self.carouselView.currentItemIndex < self.carouselView.numberOfItems && self.carouselView.currentItemIndex != self.carouselView.numberOfItems - 1) {
        leftView = [self.carouselView itemViewAtIndex: self.carouselView.currentItemIndex-1];
        rightView = [self.carouselView itemViewAtIndex: self.carouselView.currentItemIndex+1];
    } else if(self.carouselView.currentItemIndex == 0) {
        leftView = [self.carouselView itemViewAtIndex: self.carouselView.numberOfItems - 1];
        rightView = [self.carouselView itemViewAtIndex: self.carouselView.currentItemIndex+1];
    } else if(self.carouselView.currentItemIndex == self.carouselView.numberOfItems - 1) {
        leftView = [self.carouselView itemViewAtIndex: self.carouselView.numberOfItems - 2];
        rightView = [self.carouselView itemViewAtIndex: 0];
    }
    
    UIImage *captureImgLeft = [Utils captureView:leftView withArea:CGRectMake(0, 0, leftView.frame.size.width, leftView.frame.size.height)];
    UIImage *captureImgRight = [Utils captureView:rightView withArea:CGRectMake(0, 0, rightView.frame.size.width, rightView.frame.size.height)];
    
    self.captView = [[UIImageView alloc] initWithImage:captureImg];
    self.captViewLeft = [[UIImageView alloc] initWithImage:captureImgLeft];
    self.captViewRight = [[UIImageView alloc] initWithImage:captureImgRight];
    
    CGRect result = [self.view convertRect:self.carouselView.currentItemView.frame fromView:self.carouselView.currentItemView];
    CGRect resultLeft = [self.view convertRect:leftView.frame fromView:leftView];
    CGRect resultRight = [self.view convertRect:rightView.frame fromView:rightView];
    self.captView.frame = result;
    self.captViewLeft.frame = resultLeft;
    self.captViewRight.frame = resultRight;
    self.carouselView.hidden = YES;
    [self.view addSubview:self.captView];
    [self.view addSubview:self.captViewLeft];
    [self.view addSubview:self.captViewRight];
    
    CGRect originalFrame = self.captViewLeft.frame;
    self.captViewLeft.layer.anchorPoint = CGPointMake(0.0, 1.0);
    self.captViewLeft.frame = originalFrame;
    
    originalFrame = self.captViewRight.frame;
    self.captViewRight.layer.anchorPoint = CGPointMake(1.0, 1.0);
    self.captViewRight.frame = originalFrame;
    
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        
        self.captView.frame = CGRectMake(self.captView.frame.origin.x, self.captView.frame.origin.y - 450.0, self.captView.frame.size.width, self.captView.frame.size.height);
        self.captViewLeft.transform = CGAffineTransformMakeRotation(M_PI * 1.5);
        self.captViewRight.transform = CGAffineTransformMakeRotation(M_PI * -1.5);
        
    } completion:^(BOOL finished) {
    }];
    
    
    /*
     
     [UIView animateKeyframesWithDuration:1.7 delay:0.0 options:0 animations:^{
     [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.15 animations:^{
     //90 degrees (clockwise)
     
     }];
     
     } completion:^(BOOL finished) {
     
     }];
     */
    //UIStoryboard *storyBoard;
    //self.view.userInteractionEnabled = NO;
    //storyBoard = [UIStoryboard storyboardWithName:[Utils getStoryBoardName] bundle:nil];
    //HPUserProfileViewController *modal = [storyBoard instantiateViewControllerWithIdentifier:@"HPUserProfileViewController"];
    //modal.delegate = self;
    //modal.transitioningDelegate = self;
    //modal.modalPresentationStyle = UIModalPresentationCustom;
    //[self presentViewController:modal animated:YES completion:nil];
    
    
    HPUserInfoViewController* uiController = [[HPUserInfoViewController alloc] initWithNibName: @"HPUserInfoViewController" bundle: nil];
    uiController.user = [usersArr objectAtIndex:_carouselView.currentItemIndex];
    uiController.delegate = self;
    uiController.transitioningDelegate = self;
    uiController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:uiController animated:YES completion:nil];
    
    //[self.navigationController pushViewController:uiController animated:YES];
}
- (void) animationViewsDown {
    
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        
        self.captView.frame = CGRectMake(self.captView.frame.origin.x, self.captView.frame.origin.y + 450.0, self.captView.frame.size.width, self.captView.frame.size.height);
        self.captViewLeft.transform = CGAffineTransformIdentity;
        self.captViewRight.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        NSLog(@"end animation1");
        [self.captView removeFromSuperview];
        [self.captViewLeft removeFromSuperview];
        [self.captViewRight removeFromSuperview];
        self.captView = nil;
        self.captViewLeft  = nil;
        self.captViewRight =  nil;
        self.carouselView.hidden = NO;
        NSLog(@"end animation2");
        
    }];
    
}

#pragma mark - notifications
- (void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdatePointLike) name:kNeedUpdatePointLike object:nil];
}

- (void) unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdatePointLike object:nil];
}

- (void) needUpdatePointLike {
    [self.carouselView reloadData];
}


#pragma mark - init objects

- (void) initObjects
{
    [self createNavigationItem];
    [self initCarousel];
    
    
    //TODO: need fix
  //  [self fixUserCardConstraint];
    [self createGreenButton];
}

//==============================================================================

- (void) fixUserCardConstraint
{
    CGFloat topCarousel = CONSTRAINT_WIDE_TOP_FOR_CAROUSEL;
    if (![UIDevice hp_isWideScreen])
        topCarousel = CONSTRAINT_TOP_FOR_CAROUSEL;

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem: _carouselView
                                                                 attribute: NSLayoutAttributeTop
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: self.view
                                                                 attribute: NSLayoutAttributeTop
                                                                multiplier: 1.0
                                                                  constant: topCarousel]];

    if (![UIDevice hp_isWideScreen])
    {
        
        NSArray* cons = _carouselView.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeHeight) &&
                (consIter.firstItem == _carouselView))
                consIter.constant = CONSTRAINT_HEIGHT_FOR_CAROUSEL;
        }
    }
}

//==============================================================================

- (void) fixUserPointConstraint
{
}

//==============================================================================

- (void) createGreenButton
{
    HPGreenButtonVC* sendMessage = [[HPGreenButtonVC alloc] initWithNibName: @"HPGreenButtonVC" bundle: nil];
    sendMessage.view.translatesAutoresizingMaskIntoConstraints = NO;
    sendMessage.delegate = self;
    [sendMessage initObjects:@""];
    CGRect rect = sendMessage.view.frame;
    rect.origin.x = _infoButton.frame.origin.x + _infoButton.frame.size.width + SPACE_BETWEEN_GREENBUTTON_AND_INFO;
    rect.origin.y = _infoButton.frame.origin.y;
    sendMessage.view.frame = rect;

    sendMessage.delegate = self;
    [self addChildViewController: sendMessage];
    [self.view addSubview: sendMessage.view];

    [self createGreenButtonsConstraint: sendMessage];
}

//==============================================================================

- (void) createGreenButtonsConstraint: (HPGreenButtonVC*) sendMessage
{
    [sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: sendMessage.view
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: sendMessage.view.frame.size.width]];

    [sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: sendMessage.view
                                                                 attribute: NSLayoutAttributeHeight
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: sendMessage.view.frame.size.height]];

    NSArray* cons = self.view.constraints;
    for (NSLayoutConstraint* consIter in cons)
    {
        if ((consIter.firstAttribute == NSLayoutAttributeBottom) &&
            (consIter.firstItem == self.view) &&
            (consIter.secondItem == _infoButton))
            {
               [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.view
                                                                     attribute: NSLayoutAttributeBottom
                                                                     relatedBy: NSLayoutRelationEqual
                                                                        toItem: sendMessage.view
                                                                     attribute: NSLayoutAttributeBottom
                                                                    multiplier: 1.0
                                                                      constant: consIter.constant]];
            }
    }
}

//==============================================================================

- (void) initCarousel
{
    _cardOrPoint = [NSMutableArray array];
    for (NSInteger i = 0; i < ICAROUSEL_ITEMS_COUNT; i++)
        _cardOrPoint[i] = [HPUserCardOrPoint new];

    _carouselView.type = iCarouselTypeRotary;
    _carouselView.decelerationRate = 0.7;
    _carouselView.scrollEnabled = YES;
    _carouselView.exclusiveTouch = YES;
}

//==============================================================================

- (void) createNavigationItem
{
    UIBarButtonItem* chatlistButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Bubble"]
                                                        highlighedImage: [UIImage imageNamed:@"Bubble Tap"]
                                                                 action: @selector(chatsListTaped:)];
    self.notificationView = [Utils getNotificationViewForText:@"8"];
    [chatlistButton.customView addSubview: _notificationView];
    self.navigationItem.rightBarButtonItem = chatlistButton;
    
    UIBarButtonItem* backButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Close.png"]
                                                        highlighedImage: [UIImage imageNamed:@"Close Tap.png"]
                                                                 action: @selector(backbuttonTaped:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
  //  self.navigationItem.title = @"Октябрина";
}

//==============================================================================

- (UIBarButtonItem*) createBarButtonItemWithImage: (UIImage*) image
                                  highlighedImage: (UIImage*) highlighedImage
                                  action: (SEL) action
{
    UIButton* newButton = [UIButton buttonWithType: UIButtonTypeCustom];
    newButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [newButton setBackgroundImage: image forState: UIControlStateNormal];
    [newButton setBackgroundImage: highlighedImage forState: UIControlStateHighlighted];
    [newButton addTarget: self
                  action: action
        forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem* newbuttonItem = [[UIBarButtonItem alloc] initWithCustomView: newButton];

    return newbuttonItem;
}

//==============================================================================

#pragma mark - Tap events -

//==============================================================================

- (void) chatsListTaped: (id) sender
{
    NSLog(@"ChatsList taped");
}

//==============================================================================

- (void) backbuttonTaped: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

//==============================================================================

#pragma mark - iCarousel data source -

//==============================================================================

- (NSUInteger)numberOfItemsInCarousel: (iCarousel*) carousel
{
    return usersArr.count;
}

//==============================================================================

- (UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    NSLog(@"index %i", index);
    if (_cardOrPoint == nil)
        NSAssert(YES, @"no description for carousel item");
    User *user = [usersArr objectAtIndex:index];
    view = [[HPUserCardOrPointView alloc] initWithCardOrPoint: _cardOrPoint[index] user: user
                                                     delegate: self];

    return view;
}

//==============================================================================

#pragma mark - iCarousel delegate -

//==============================================================================

- (CGFloat)carousel: (iCarousel *)carousel valueForOption: (iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionFadeMin:
            return -1;
        case iCarouselOptionFadeMax:
            return 1;
        case iCarouselOptionFadeRange:
            return 2.0;
        case iCarouselOptionCount:
            return 10;
        case iCarouselOptionSpacing:
            return value * 1.3;
        default:
            return value;
    }
}

//==============================================================================

- (CGFloat)carouselItemWidth:(iCarousel*)carousel
{
    return ICAROUSEL_ITEMS_WIDTH;
}

//==============================================================================

#pragma mark - Slide buttons -

//==============================================================================

- (IBAction) slideLeftPressed: (id)sender
{
    NSInteger currentItemIndex = _carouselView.currentItemIndex;
    NSInteger itemIndexToScrollTo = _carouselView.currentItemIndex - 1;
    if (currentItemIndex == 0)
        itemIndexToScrollTo = _carouselView.numberOfItems - 1;
    
    [_carouselView scrollToItemAtIndex: itemIndexToScrollTo animated: YES];
}

//==============================================================================

- (IBAction) slideRightPressed: (id)sender
{
    NSInteger currentItemIndex = _carouselView.currentItemIndex;
    NSInteger itemIndexToScrollTo = _carouselView.currentItemIndex + 1;
    if (currentItemIndex >= _carouselView.numberOfItems)
        itemIndexToScrollTo = 0;
    
    [_carouselView scrollToItemAtIndex: itemIndexToScrollTo animated: YES];
}

//==============================================================================

#pragma mark - Buttons pressed -

//==============================================================================

- (void) greenButtonPressed: (HPGreenButtonVC*) button
{
    NSLog(@"Green button pressed");
}

//==============================================================================

- (IBAction) infoButtonPressed: (id)sender
{
    [self animationViewsUp];
}

//==============================================================================

#pragma mark - User card delegate -

//==============================================================================

- (void) switchButtonPressed
{
    HPUserCardOrPointView* container = (HPUserCardOrPointView*)self.carouselView.currentItemView;
    [_cardOrPoint[_carouselView.currentItemIndex] switchUserPoint];
    
    User *user = [usersArr objectAtIndex:_carouselView.currentItemIndex];
    [UIView transitionWithView: container
                      duration: FLIP_ANIMATION_SPEED
                       options: UIViewAnimationOptionTransitionFlipFromRight
                    animations: ^{
                        [container switchSidesWithCardOrPoint: _cardOrPoint[_carouselView.currentItemIndex] user:user
                                                     delegate: self];
                    }
                    completion: ^(BOOL finished){
                }];
}

//==============================================================================

- (void) heartTapped
{
    UserPoint *point = ((User *)[usersArr objectAtIndex:self.carouselView.currentItemIndex]).point;
    if ([point.pointLiked boolValue]) {
        //unlike request
        [[HPBaseNetworkManager sharedNetworkManager] makePointUnLikeRequest:point.pointId];
    } else {
        //like request
        [[HPBaseNetworkManager sharedNetworkManager] makePointLikeRequest:point.pointId];
    }
    
    
    
    
    NSLog(@"heart tapped");
}

//==============================================================================

@end
