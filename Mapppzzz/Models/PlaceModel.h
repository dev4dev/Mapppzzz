//
//  PlaceModel.h
//  Mapppzzz
//
//  Created by Alex Antonyuk on 9/3/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface PlaceModel : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinates;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
