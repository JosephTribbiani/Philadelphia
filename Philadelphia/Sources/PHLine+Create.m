//
//  PHLine+Create.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/17/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHLine+Create.h"

@implementation PHLine (Create)

+ (PHLine*)lineWithInfo:(NSDictionary*)info inManagedObjectContext:(NSManagedObjectContext*)context
{
    PHLine* line = nil;
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"PHLine"];
    request.predicate = [NSPredicate predicateWithFormat:@"lineId = %@",[info objectForKey:@"lineId"]];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if ([matches count] != 0)
    {
        // remove item
    }
    else
    {
        line = [NSEntityDescription insertNewObjectForEntityForName:@"PHLine" inManagedObjectContext:context];
        line.lineId = info[@"lineId"];
        line.shapes = info[@"shapes"];
        line.name = info[@"name"];
        
        line.crosses = [NSJSONSerialization dataWithJSONObject:info[@"crosses"] options:0 error:NULL];
    }
    return line;
}

@end
