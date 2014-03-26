//
//  PHLine.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/26/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHStation, PHTrain;

@interface PHLine : NSManagedObject

@property (nonatomic, retain) NSData * crosses;
@property (nonatomic, retain) NSString * lineId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * shapes;
@property (nonatomic, retain) NSSet *stations;
@property (nonatomic, retain) NSSet *trains;
@end

@interface PHLine (CoreDataGeneratedAccessors)

- (void)addStationsObject:(PHStation *)value;
- (void)removeStationsObject:(PHStation *)value;
- (void)addStations:(NSSet *)values;
- (void)removeStations:(NSSet *)values;

- (void)addTrainsObject:(PHTrain *)value;
- (void)removeTrainsObject:(PHTrain *)value;
- (void)addTrains:(NSSet *)values;
- (void)removeTrains:(NSSet *)values;

@end
