//
//  PHStation+Create.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/18/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHStation.h"

@interface PHStation (Utils)

+ (PHStation*)stationWithInfo:(NSDictionary*)info inManagedObjectContext:(NSManagedObjectContext*)context;
- (NSInteger)positionForLine:(PHLine*)line direction:(NSUInteger)direction;
- (NSSet*)passingTrains;

@end
