//
//  PHSpecificRoute.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/13/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PHSpecificRoute : NSManagedObject

@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSSet *stops;
@property (nonatomic, retain) NSManagedObject *route;
@end

@interface PHSpecificRoute (CoreDataGeneratedAccessors)

- (void)addStopsObject:(NSManagedObject *)value;
- (void)removeStopsObject:(NSManagedObject *)value;
- (void)addStops:(NSSet *)values;
- (void)removeStops:(NSSet *)values;

@end
