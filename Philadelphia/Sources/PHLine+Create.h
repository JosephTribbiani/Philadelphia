//
//  PHLine+Create.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/17/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHLine.h"

@interface PHLine (Create)

+ (PHLine*)lineWithInfo:(NSDictionary*)info inManagedObjectContext:(NSManagedObjectContext*)context;

@end
