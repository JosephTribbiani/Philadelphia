//
//  PHLine.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/14/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHPoint, PHPosition, PHRoute;

@interface PHLine : NSManagedObject

@property (nonatomic, retain) NSString * lineId;
@property (nonatomic, retain) NSSet *points;
@property (nonatomic, retain) NSSet *positions;
@property (nonatomic, retain) NSSet *routes;
@end

@interface PHLine (CoreDataGeneratedAccessors)

- (void)addPointsObject:(PHPoint *)value;
- (void)removePointsObject:(PHPoint *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;

- (void)addPositionsObject:(PHPosition *)value;
- (void)removePositionsObject:(PHPosition *)value;
- (void)addPositions:(NSSet *)values;
- (void)removePositions:(NSSet *)values;

- (void)addRoutesObject:(PHRoute *)value;
- (void)removeRoutesObject:(PHRoute *)value;
- (void)addRoutes:(NSSet *)values;
- (void)removeRoutes:(NSSet *)values;

@end
