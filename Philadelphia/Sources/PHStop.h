//
//  PHStop.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/14/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHSpecificRoute, PHStation;

@interface PHStop : NSManagedObject

@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) PHSpecificRoute *specificRoute;
@property (nonatomic, retain) PHStation *station;

@end
