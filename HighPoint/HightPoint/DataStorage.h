//
//  DataStorage.h
//  iQLib
//
//  Created by Andrey Anisimov on 07.07.13.
//  Copyright (c) 2013 Andrey Anisimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppSetting.h"
#import "UserFilter.h"
#import "User.h"
#import "MinEntertainmentPrice.h"
#import "MaxEntertainmentPrice.h"
#import "Gender.h"
#import "Education.h"
#import "Career.h"
#import "Avatar.h"
#import "UserPoint.h"

@interface DataStorage : NSObject
@property (nonatomic, strong) NSManagedObjectContext *moc;
+ (DataStorage*) sharedDataStorage;
- (void) createUser:(NSDictionary*) param;
- (void) createPoint:(NSDictionary*) param;
- (void) createUserInfo:(NSDictionary*) param;
- (void) createUserSettings:(NSDictionary*) param;
- (void) createApplicationSettingEntity:(NSDictionary *)param;
- (UserFilter*) createUserFilterEntity:(NSDictionary *)param;
- (void) deleteUserFilter;
- (UserFilter*) getUserFilter;
- (NSFetchedResultsController*) applicationSettingFetchResultsController;
- (void) createUserEntity:(NSDictionary *)param isCurrent:(BOOL) current;
- (NSFetchedResultsController*) allUsersFetchResultsController;
- (User*) getCurrentUser;
- (UserPoint*) getPointForUserId:(NSNumber*) userId;
- (AppSetting*) getAppSettings;
- (void) saveContext;
@end
