//
//  PHStation.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/13/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHPosition, PHStop;

@interface PHStation : NSManagedObject

@property (nonatomic, retain) NSString * stationId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *positions;
@property (nonatomic, retain) NSSet *stops;
@end

@interface PHStation (CoreDataGeneratedAccessors)

- (void)addPositionsObject:(PHPosition *)value;
- (void)removePositionsObject:(PHPosition *)value;
- (void)addPositions:(NSSet *)values;
- (void)removePositions:(NSSet *)values;

- (void)addStopsObject:(PHStop *)value;
- (void)removeStopsObject:(PHStop *)value;
- (void)addStops:(NSSet *)values;
- (void)removeStops:(NSSet *)values;

@end
