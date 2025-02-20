//
//  HPBaseNetworkManager+Geo.h
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager.h"
#import "DataStorage.h"
@interface HPBaseNetworkManager (Geo)
- (void) getGeoLocation:(NSDictionary*) param;
- (void) getPopularCitiesRequest;
- (void) findGeoLocation:(NSDictionary*) param;
- (void) getGeoLocationForPlaces:(NSDictionary*) param withBlock:(complationBlock) block;
@end
