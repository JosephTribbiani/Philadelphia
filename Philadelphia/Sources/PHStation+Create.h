//
//  PHStation+Create.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/18/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHStation.h"

@interface PHStation (Create)

+ (PHStation*)stationWithInfo:(NSDictionary*)info inManagedObjectContext:(NSManagedObjectContext*)context;

@end
