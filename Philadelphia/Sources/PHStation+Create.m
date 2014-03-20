//
//  PHStation+Create.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/18/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHStation+Create.h"
#import "PHLine+Create.h"
#import "PHTrain+Create.h"

@implementation PHStation (Create)

+ (PHStation*)stationWithInfo:(NSDictionary*)info trains:(NSArray*)trainsInfo inManagedObjectContext:(NSManagedObjectContext*)context;
{
    PHStation* station = nil;
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"PHStation"];
    request.predicate = [NSPredicate predicateWithFormat:@"stopId = %@",[info objectForKey:@"stopId"]];
    NSError* error = nil;
    NSArray* matches = [context executeFetchRequest:request error:&error];
    
    if ([matches count] != 0)
    {
        // remove item
    }
    else
    {
        station = [NSEntityDescription insertNewObjectForEntityForName:@"PHStation" inManagedObjectContext:context];
        station.stopId = info[@"stopId"];
        station.name = info[@"name"];
        station.latitude = info[@"latitude"];
        station.longitude = info[@"longitude"];
        
        // setting lines
        NSMutableSet* lines = [station mutableSetValueForKey:@"lines"];
        for (NSString* lineId in info[@"lines"])
        {
            NSFetchRequest* lineRequest = [NSFetchRequest fetchRequestWithEntityName:@"PHLine"];
            lineRequest.predicate = [NSPredicate predicateWithFormat:@"lineId = %@",lineId];
            NSError* error = nil;
            NSArray* matches = [context executeFetchRequest:lineRequest error:&error];
            if ([matches count] == 0)
            {
                // create PHLine
            }
            else if ([matches count] == 1)
            {
                [lines addObject:[matches firstObject]];
            }
            else
            {
                // another error
            }
        }
        
        //settings trains
        NSMutableSet* trains = [station mutableSetValueForKey:@"trains"];
        for (NSDictionary* train in trainsInfo)
        {
            for (NSDictionary* trainSchedule in train[@"trainSchedule"])
            {
                NSArray* stopIds = [[trainSchedule objectForKey:@"schedule"] allKeys];
                NSString* stopId = station.stopId;
                
                if ([stopIds containsObject:stopId])
                {
                    NSFetchRequest* lineRequest = [NSFetchRequest fetchRequestWithEntityName:@"PHTrain"];
                    lineRequest.predicate = [NSPredicate predicateWithFormat:@"signature = %@",train[@"signature"]];
                    NSError* error = nil;
                    NSArray* matches = [context executeFetchRequest:lineRequest error:&error];
                    if ([matches count] == 0)
                    {
                        PHTrain* newTrain = [PHTrain trainWithInfo:train inManagedObjectContext:context];
                        [trains addObject:newTrain];
                    }
                    else if ([matches count] == 1)
                    {
                        [trains addObject:[matches firstObject]];
                    }
                    else
                    {
                        // another error
                    }
                }
            }
        }
    }
    return station;
}

@end
