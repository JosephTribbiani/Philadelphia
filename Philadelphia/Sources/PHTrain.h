//
//  PHTrain.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/20/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHStation;

@interface PHTrain : NSManagedObject

@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSData * schedule;
@property (nonatomic, retain) NSSet *stations;
@end

@interface PHTrain (CoreDataGeneratedAccessors)

- (void)addStationsObject:(PHStation *)value;
- (void)removeStationsObject:(PHStation *)value;
- (void)addStations:(NSSet *)values;
- (void)removeStations:(NSSet *)values;

@end
