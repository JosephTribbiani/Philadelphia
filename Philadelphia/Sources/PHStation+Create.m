//
//  PHStation+Create.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/18/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHStation+Create.h"
#import "PHLine+Create.h"

@implementation PHStation (Create)

+ (PHStation*)stationWithInfo:(NSDictionary*)info inManagedObjectContext:(NSManagedObjectContext*)context
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
    }
    return station;
}

@end
