//
//  PHLine.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/19/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHStation;

@interface PHLine : NSManagedObject

@property (nonatomic, retain) NSString * lineId;
@property (nonatomic, retain) NSData * shapes;
@property (nonatomic, retain) NSData * crosses;
@property (nonatomic, retain) NSSet *stations;
@end

@interface PHLine (CoreDataGeneratedAccessors)

- (void)addStationsObject:(PHStation *)value;
- (void)removeStationsObject:(PHStation *)value;
- (void)addStations:(NSSet *)values;
- (void)removeStations:(NSSet *)values;

@end
