//
//  PHSpecificRoute.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/14/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHRoute, PHStop;

@interface PHSpecificRoute : NSManagedObject

@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) PHRoute *route;
@property (nonatomic, retain) NSSet *stops;
@end

@interface PHSpecificRoute (CoreDataGeneratedAccessors)

- (void)addStopsObject:(PHStop *)value;
- (void)removeStopsObject:(PHStop *)value;
- (void)addStops:(NSSet *)values;
- (void)removeStops:(NSSet *)values;

@end
