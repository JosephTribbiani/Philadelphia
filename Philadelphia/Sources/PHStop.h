//
//  PHStop.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/13/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHSpecificRoute;

@interface PHStop : NSManagedObject

@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSManagedObject *station;
@property (nonatomic, retain) PHSpecificRoute *specificRoute;

@end
