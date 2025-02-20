//
//  User.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 05.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


typedef NS_ENUM(NSUInteger, UserVisibilityType){
    UserVisibilityVisible = 1,
    UserVisibilityBlur = 2,
    UserVisibilityHidden = 3,
    UserVisibilityRequestBlur = 4,
    UserVisibilityRequestHidden = 5
};

typedef NS_ENUM(NSUInteger, UserGenderType){
    UserGenderNone = 0,
    UserGenderMale = 1,
    UserGenderFemale = 2,
};

@class Avatar, Career, Chat, City, Contact, Education, Language, MaxEntertainmentPrice, MinEntertainmentPrice, Place, UserFilter, UserPoint;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * cityId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * dateOfBirth;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * favoriteCityIds;
@property (nonatomic, retain) NSString * favoritePlaceIds;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSNumber * isCurrentUser;
@property (nonatomic, retain) NSNumber * isItFromContact;
@property (nonatomic, retain) NSNumber * isItFromMainList;
@property (nonatomic, retain) NSNumber * isItFromPointLike;
@property (nonatomic, retain) NSString * languageIds;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nameForms;
@property (nonatomic, retain) NSNumber * online;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * visibility;
@property (nonatomic, retain) Avatar *avatar;
@property (nonatomic, retain) NSSet *career;
@property (nonatomic, retain) Chat *chat;
@property (nonatomic, retain) City *city;
@property (nonatomic, retain) Contact *contact;
@property (nonatomic, retain) NSSet *education;
@property (nonatomic, retain) NSSet *language;
@property (nonatomic, retain) NSSet *likedPosts;
@property (nonatomic, retain) MaxEntertainmentPrice *maxentertainment;
@property (nonatomic, retain) MinEntertainmentPrice *minentertainment;
@property (nonatomic, retain) NSSet *place;
@property (nonatomic, retain) UserPoint *point;
@property (nonatomic, retain) UserFilter *userfilter;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCareerObject:(Career *)value;
- (void)removeCareerObject:(Career *)value;
- (void)addCareer:(NSSet *)values;
- (void)removeCareer:(NSSet *)values;

- (void)addEducationObject:(Education *)value;
- (void)removeEducationObject:(Education *)value;
- (void)addEducation:(NSSet *)values;
- (void)removeEducation:(NSSet *)values;

- (void)addLanguageObject:(Language *)value;
- (void)removeLanguageObject:(Language *)value;
- (void)addLanguage:(NSSet *)values;
- (void)removeLanguage:(NSSet *)values;

- (void)addLikedPostsObject:(UserPoint *)value;
- (void)removeLikedPostsObject:(UserPoint *)value;
- (void)addLikedPosts:(NSSet *)values;
- (void)removeLikedPosts:(NSSet *)values;

- (void)addPlaceObject:(Place *)value;
- (void)removePlaceObject:(Place *)value;
- (void)addPlace:(NSSet *)values;
- (void)removePlace:(NSSet *)values;

@end
