//
//  PHTrain+Create.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/20/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHTrain.h"

@interface PHTrain (Create)

+ (PHTrain*)trainWithInfo:(NSDictionary*)info inManagedObjectContext:(NSManagedObjectContext*)context;

@end
