//
//  FoursquareClient.h
//  Mapppzzz
//
//  Created by Alex Antonyuk on 9/3/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

typedef void(^FoursquareSearchResponseBlock)(NSArray *places, NSError *error);

@interface FoursquareClient : NSObject

+ (instancetype)sharedClient;

- (void)searchPlacesNearLocation:(CLLocation *)location completion:(FoursquareSearchResponseBlock)completion;

@end
