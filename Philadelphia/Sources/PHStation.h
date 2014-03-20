//
//  PHStation.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/20/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHLine, PHTrain;

@interface PHStation : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * stopId;
@property (nonatomic, retain) NSSet *lines;
@property (nonatomic, retain) NSSet *trains;
@end

@interface PHStation (CoreDataGeneratedAccessors)

- (void)addLinesObject:(PHLine *)value;
- (void)removeLinesObject:(PHLine *)value;
- (void)addLines:(NSSet *)values;
- (void)removeLines:(NSSet *)values;

- (void)addTrainsObject:(PHTrain *)value;
- (void)removeTrainsObject:(PHTrain *)value;
- (void)addTrains:(NSSet *)values;
- (void)removeTrains:(NSSet *)values;

@end
