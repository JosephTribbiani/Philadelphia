//
//  PHStation+Create.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/18/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHStation+Utils.h"
#import "PHLine+Create.h"
#import "PHTrain+Create.h"

@implementation PHStation (Utils)

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
        station.positions = [NSJSONSerialization dataWithJSONObject:info[@"positions"] options:0 error:NULL];
        
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
    }
    return station;
}

- (NSInteger)positionForLine:(PHLine*)line direction:(NSUInteger)direction
{
    NSDictionary* positions = [NSJSONSerialization JSONObjectWithData:self.positions options:0 error:NULL];
    return [[[positions objectForKey:line.lineId] objectForKey:[NSString stringWithFormat:@"%d",direction]] integerValue];
}

- (NSSet*)passingTrains
{
    NSMutableSet* result = [NSMutableSet new];
    for (PHLine* line in self.lines)
    {
        for (PHTrain* train in line.trains)
        {
            NSArray* schedules = [NSJSONSerialization JSONObjectWithData:train.schedule options:0 error:NULL];
            for (NSDictionary* schedule in schedules)
            {
                NSArray* stopIds = [[schedule objectForKey:@"schedule"] allKeys];
                for (NSString* stopId in stopIds)
                {
                    if ([stopId isEqualToString:self.stopId])
                    {
                        [result addObject:train];
                    }
                }
            }
        }
    }
    return [result count] > 0 ? [NSSet setWithSet:result] : nil;
}

@end
