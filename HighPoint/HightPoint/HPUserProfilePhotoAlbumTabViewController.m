//
// Created by Eugene on 22.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserProfilePhotoAlbumTabViewController.h"
#import "HPImageCollectionViewCell.h"
#import "HPAddPhotoMenuViewController.h"
#import "Utils.h"
#import "UIImage+HighPoint.h"
#import "HPUserProfileCarouselModeViewController.h"
#import "DataStorage.h"
#import "Photo.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "HPBaseNetworkManager+Photos.h"
#import "NotificationsConstants.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"

@interface HPUserProfilePhotoAlbumTabViewController()
@property (nonatomic, retain) NSMutableArray* photosArray;
@end

@implementation HPUserProfilePhotoAlbumTabViewController

static NSString *cellID = @"cellID";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HPImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:cellID];
    [self reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kNeedUpdateUserPhotos object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateUserPhotos object:nil];
}

- (void) reloadData {
    NSArray *photos = [[DataStorage sharedDataStorage] getPhotoForUserId:self.user.userId];
    _photosArray = nil;
    _photosArray = [NSMutableArray arrayWithArray:photos];
    [self.collectionView reloadData];
}

#pragma mark - collection view
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //if(self.user.isCurrentUser.boolValue)
        return _photosArray.count+1;
    //else
    //    return _photosArray.count;
}

- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 5.f;
}

- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 5.f;
}

- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 5.f;
}

- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForLargeItemsInSection:(NSInteger)section
{
    return RACollectionViewTripletLayoutStyleSquare; //same as default !
}

- (UIEdgeInsets)autoScrollTrigerEdgeInsets:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(50.f, 0, 50.f, 0);

}

- (UIEdgeInsets)autoScrollTrigerPadding:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(64.f, 0, 0, 0);

}

- (CGFloat)reorderingItemAlpha:(UICollectionView *)collectionview
{
    return .3f;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    UIImage *image = _photosArray[(NSUInteger) fromIndexPath.item];
    [_photosArray removeObjectAtIndex:(NSUInteger) fromIndexPath.item];
    [_photosArray insertObject:image atIndex:(NSUInteger) toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    return !([self collectionView:collectionView numberOfItemsInSection:toIndexPath.section] - toIndexPath.row == 1);
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return !([self collectionView:collectionView numberOfItemsInSection:indexPath.section] - indexPath.row == 1);
}
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HPImageCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.imageView.image = nil;
    //[cell.imageView removeFromSuperview];
    cell.imageView.frame = cell.bounds;
    
    if(self.photosArray.count  - indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"Camera"];
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];

        cell.contentView.layer.borderWidth = 1.5;
        cell.contentView.layer.borderColor =  [UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1].CGColor;

    } else {
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        Photo *photo = [self.photosArray objectAtIndex:indexPath.row];
        if([photo.photoId intValue] > 0) {
            NSString* avatarUrl = photo.imgeSrc;
            
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL
                                            URLWithString:avatarUrl]
                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
            [cell.imageView setImageWithURLRequest:request placeholderImage:nil success:nil failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                
            }];
            /*
            [self downloadImageWithURL:[NSURL URLWithString:avatarUrl] completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    // change the image in the cell
                    cell.imageView.image = image;
                    
                    // cache the image for use later (when scrolling up)
                    //cell.imageView.image = image;
                } else cell.imageView.image = nil;
                
            }];
            
            //[self sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
            
            //[cell.imageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl]
            //               placeholderImage:nil
            //                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //                      cell.contentView.layer.borderColor =  [UIColor clearColor].CGColor;
            //                      }];
            
            /*
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:avatarUrl]
                                  options:SDWebImageRetryFailed
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize)
             {
                 // progression tracking code
             }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *url)
             {
                 if (image)
                 {
                     NSLog(@"image width %f", image.size.width);
                     NSLog(@"image height %f", image.size.height);
                     
                     cell.imageView.image = image;
                     cell.contentView.layer.borderColor =  [UIColor clearColor].CGColor;
                     
                 }
             }];
             */
            
        } else {
            NSLog(@"Error: get from ALLibrary");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                [assetsLibrary assetForURL:[NSURL URLWithString:photo.imgeSrc] resultBlock: ^(ALAsset *asset)   {
                    
                    @autoreleasepool {
                        ALAssetRepresentation *representation = [asset defaultRepresentation];
                        CGImageRef imageRef = [representation fullScreenImage];
                        if (imageRef) {
                            UIImage* image = [UIImage imageWithCGImage:imageRef
                                                                 scale:representation.scale
                                                           orientation:(UIImageOrientation) representation.orientation];
                            
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                cell.imageView.image = image;
                            });
                            
                        }
                    }
                } failureBlock:^(NSError *error)    {
                    
                }];
                
            });
        }
    }
    [cell addSubview:cell.imageView];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_photosArray.count - indexPath.row == 0) {
        [self addPhotoMenuShow];
    } else {
        HPUserProfileCarouselModeViewController* carouselViewController = [[HPUserProfileCarouselModeViewController alloc] initWithNibName:@"HPUserProfileCarouselModeViewController" bundle:nil];
        carouselViewController.photosArray = _photosArray;
        carouselViewController.selectedPhoto = indexPath.row;
        [self.navigationController pushViewController:carouselViewController animated:YES];    }
}

- (void) addPhotoMenuShow {
    HPAddPhotoMenuViewController* addPhotoViewController = [[HPAddPhotoMenuViewController alloc] initWithNibName: @"HPAddPhotoMenuViewController" bundle: nil];
    addPhotoViewController.delegate = self;
    addPhotoViewController.screenShoot = [self selfScreenShot];
    [self presentViewController:addPhotoViewController animated:YES completion:nil];
}

- (void) viewWillBeHidden:(UIImage*) image andIntPath:(NSString *)path {
    //UIImage *img = [Utils scaleImage:image toSize:CGSizeMake(320.0, 320.0)];
    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *fakeId = [NSNumber numberWithInt: (int) timeStamp * -1];
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:fakeId,@"id",[NSNumber numberWithFloat:image.size.width],@"imgwidth",[NSNumber numberWithFloat:image.size.height],@"imgheight",path, @"imgsrc", nil];
    [[DataStorage sharedDataStorage] createAndSaveIntPhotoEntity:param withComplation:^(id object) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self reloadData];
        [[HPBaseNetworkManager sharedNetworkManager] addPhotoRequest:image andPhotoId:fakeId];
    }];
}

- (void) closeMenu {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage*) selfScreenShot {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow frame];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *capturedScreen = [UIGraphicsGetImageFromCurrentImageContext() resizeImageToSize:(CGSize){rect.size.width/3, rect.size.height/3}];
    UIGraphicsEndImageContext();
    return capturedScreen;
}
@end