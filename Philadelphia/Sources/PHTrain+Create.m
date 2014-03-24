//
//  PHTrain+Create.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/20/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHTrain+Create.h"

@implementation PHTrain (Create)

+ (PHTrain*)trainWithInfo:(NSDictionary*)info inManagedObjectContext:(NSManagedObjectContext*)context
{
    PHTrain* train = nil;
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"PHTrain"];
    request.predicate = [NSPredicate predicateWithFormat:@"signature = %@",[info objectForKey:@"signature"]];
    NSError* error = nil;
    NSArray* matches = [context executeFetchRequest:request error:&error];
    
    if ([matches count] != 0)
    {
        // remove item
    }
    else
    {
        train = [NSEntityDescription insertNewObjectForEntityForName:@"PHTrain" inManagedObjectContext:context];
        train.signature = info[@"signature"];
        train.schedule = [NSJSONSerialization dataWithJSONObject:info[@"trainSchedule"]options:0 error:NULL];
        train.direction = info[@"direction"];
        
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"PHLine"];
        request.predicate = [NSPredicate predicateWithFormat:@"lineId = %@",[info objectForKey:@"lineId"]];
        PHLine* line = [[context executeFetchRequest:request error:NULL] lastObject];
        train.line = line;
        
    }
    return train;
}

@end
