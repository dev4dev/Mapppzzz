//
//  FoursquareClient.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 9/3/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "FoursquareClient.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFURLRequestSerialization.h>
#import <AFNetworking/AFURLResponseSerialization.h>
#import <YOLOKit/YOLO.h>
#import "PlaceModel.h"
#import <Keys/MapKeys.h>

@interface FoursquareClient ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *httpManager;
@property (nonatomic, strong) MapKeys *keys;

@end

@implementation FoursquareClient

#pragma mark - Init & Dealloc

+ (instancetype)sharedClient
{
	static dispatch_once_t once;
	static FoursquareClient *instance;
	dispatch_once(&once, ^ {
		instance = [[FoursquareClient alloc] init];
	});
	return instance;
}

- (instancetype)init
{
	if (self = [super init]) {
		_httpManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.foursquare.com/v2/"]];
		_httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
		_httpManager.responseSerializer = [AFJSONResponseSerializer serializer];

		_keys = [MapKeys new];
	}

	return self;
}

#pragma mark - Lifecycle (Setup/Update)


#pragma mark - Properties Getters


#pragma mark - Properties Setters

- (NSDictionary *)addAuthInfoToParams:(NSDictionary *)parameters
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parameters];
	[dict addEntriesFromDictionary:@{
		@"client_id": self.keys.clientId,
		@"client_secret": self.keys.clientSecret
	}];
	return [dict copy];
}

#pragma mark - Public Interface

- (void)searchPlacesNearLocation:(CLLocation *)location completion:(FoursquareSearchResponseBlock)completion
{
	if (!location) {
		if (completion) {
			completion(nil, [NSError errorWithDomain:@"Woops" code:-1 userInfo:nil]);
		}
		return;
	}

	NSDictionary* parameters = @{
		@"v": @"20140806",
		@"ll": [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude]
	};
	[self.httpManager GET:@"venues/search" parameters:[self  addAuthInfoToParams:parameters] success:^(AFHTTPRequestOperation *operation, id jsonResponse) {
		NSDictionary *response = jsonResponse;
		NSArray *places = [response valueForKeyPath:@"response.venues"];
		NSArray *placesModels = places.map(^id(NSDictionary *placeDict){
			return [[PlaceModel alloc] initWithDictionary:placeDict];
		});
		if (completion) {
			completion(placesModels, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (completion) {
			completion(nil, error);
		}
	}];
}

#pragma mark - Private methods



@end
