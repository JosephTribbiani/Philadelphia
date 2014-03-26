//
//  PHDataManager.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/14/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHNetworkingManager.h"
#import "AFNetworking/AFNetworking.h"

@interface PHNetworkingManager()

@property (nonatomic, strong) AFJSONResponseSerializer* responseSerializer;

@end

@implementation PHNetworkingManager

- (AFJSONResponseSerializer*)responseSerializer
{
    if (nil == _responseSerializer)
    {
        _responseSerializer = [AFJSONResponseSerializer new];
    }
    return _responseSerializer;
}

- (void)requestTransportInfoWithCompletionHandler:(void(^)(NSDictionary* transportInfo))completionHandler
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://shopandride.cogniance.com/parcsr-ci/rest/transport/schedule?previousUpdateUtm=0"]];
    request.HTTPMethod = @"GET";
    
    AFHTTPRequestOperation* requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.securityPolicy.allowInvalidCertificates = YES;
    requestOperation.responseSerializer = self.responseSerializer;
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (completionHandler)
        {
            NSMutableArray* linesMutable = [NSMutableArray new];
            NSMutableArray* stopsMutable = [NSMutableArray new];
            
            // line views
            NSArray* lines = responseObject[@"lineViews"];
            for (NSDictionary* line in lines)
            {
                NSData* shapes = [NSJSONSerialization dataWithJSONObject:line[@"shape"] options:0 error:NULL];
                NSString* lineId = line[@"lineId"];
                NSMutableDictionary* mutableLine = [NSMutableDictionary dictionaryWithDictionary:@{@"shapes" : shapes,
                                                                                                   @"lineId" : lineId,
                                                                                                   @"crosses" : [NSMutableArray new]}]; //placeholder for crosses
                [linesMutable addObject:mutableLine];
            }
            
            // stop views
            NSArray* stopes = responseObject[@"stopViews"];
            for (NSDictionary* stop in stopes)
            {
                NSMutableArray* lineIds = [NSMutableArray new];
                NSMutableDictionary* stationPositions = [NSMutableDictionary new];
                NSArray* positions = stop[@"positions"];
                for (NSArray* position in positions)
                {
                    [lineIds addObject:position[0]];
                    NSMutableDictionary* linePosition = [stationPositions objectForKey:position[0]];
                    if (linePosition == nil)
                    {
                        linePosition = [NSMutableDictionary new];
                        [stationPositions setObject:linePosition forKey:position[0]];
                    }
                    NSString* direction = position[1];
                    NSString* sequenceNumber = position[2];
                    [linePosition setObject:sequenceNumber forKey:direction];
                }
                
                // calculate crosses
                NSMutableSet* crossedLines = [NSMutableSet setWithArray:lineIds]; //remove duplicates from array
                
                if ([crossedLines count] > 1) // not only itself
                {
                    for (NSMutableDictionary* line in linesMutable)
                    {
                        if ([crossedLines containsObject:line[@"lineId"]])
                        {
                            NSMutableSet* crossedLinesCopy = [crossedLines mutableCopy];
                            [crossedLinesCopy removeObject:line[@"lineId"]];
                            NSMutableDictionary* crossStation = [NSMutableDictionary dictionaryWithDictionary:@{[NSString stringWithFormat:@"%@", stop[@"stopId"]] : [crossedLinesCopy allObjects]}];
                            NSMutableArray* crosses = [line objectForKey:@"crosses"];
                            [crosses addObject:crossStation];
                        }
                    }
                }
                
                NSMutableDictionary* mutableStop = [NSMutableDictionary dictionaryWithDictionary:@{@"stopId" : [NSString stringWithFormat:@"%@", stop[@"stopId"]] ,
                                                                                                   @"name" : stop[@"name"],
                                                                                                   @"latitude" : stop[@"lat"],
                                                                                                   @"longitude" : stop[@"lon"],
                                                                                                   @"lines" : lineIds,
                                                                                                   @"positions" : stationPositions,
                                                                                                   @"trains" : [NSMutableArray new]}]; // trains placeholder
                [stopsMutable addObject:mutableStop];
            }
            
            // routeViews
            NSArray* routes = responseObject[@"virtualRouteViews"];
            NSMutableArray* trains = [NSMutableArray new];
            for (NSDictionary* route in routes)
            {
                for (NSMutableDictionary* mutableLine in linesMutable)
                {
                    if ([[mutableLine objectForKey:@"lineId"] isEqualToString:route[@"lineId"]])
                    {
                        [mutableLine setObject:route[@"name"] forKey:@"name"];
                    }
                }
                NSArray* specificRoutes = route[@"specificRoutes"];
                for (NSDictionary* specificRoute in specificRoutes)
                {
                    NSMutableDictionary* train = [NSMutableDictionary new];
                    [train setObject:specificRoute[@"signature"] forKey:@"signature"];
                    
                    NSArray* schedules = specificRoute[@"schedules"];
                    NSMutableArray* trainSchedule = [NSMutableArray new];
                    for (NSDictionary* schedule in schedules)
                    {
                        NSMutableDictionary* timeStationTable = [NSMutableDictionary new];
                        NSArray* launches = schedule[@"launches"];
                        for (NSNumber* launch in launches)
                        {
                            NSArray *patterns = [NSMutableArray arrayWithArray:specificRoute[@"pattern"]];
                            for (NSArray* pattern in patterns)
                            {
                                NSInteger stopTime = [pattern[1] integerValue] + [launch integerValue];
                                NSString* stopId = [pattern[0] stringValue];
                                NSMutableArray* stopTimes = [timeStationTable objectForKey:stopId];
                                if (stopTimes == nil)
                                {
                                    stopTimes = [NSMutableArray new];
                                    [timeStationTable setObject:stopTimes forKey:stopId];
                                }
                                [stopTimes addObject:@(stopTime)];
                            }
                        }
                        [trainSchedule addObject:@{@"days" : schedule[@"days"],
                                                   @"schedule" : timeStationTable}];
                        
                    }
                    [train setObject:trainSchedule forKey:@"trainSchedule"];
                    
                    [train setObject:@([route[@"directionId"] integerValue]) forKey:@"direction"];
                    [train setObject:route[@"lineId"] forKey:@"lineId"];
                    [trains addObject:train];
                }
            }

            completionHandler(@{@"lines" : [NSArray arrayWithArray:linesMutable],
                                @"stops" : [NSArray arrayWithArray:stopsMutable],
                                @"trains" : [NSArray arrayWithArray:trains]});
        }
    }
    failure:^(AFHTTPRequestOperation* operation, NSError* error)
    {
        if (completionHandler)
        {
            completionHandler(nil);
        }
    }];
    [requestOperation start];
}

@end
