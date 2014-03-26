//
//  PHStation.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/26/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHLine;

@interface PHStation : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * positions;
@property (nonatomic, retain) NSString * stopId;
@property (nonatomic, retain) NSSet *lines;
@end

@interface PHStation (CoreDataGeneratedAccessors)

- (void)addLinesObject:(PHLine *)value;
- (void)removeLinesObject:(PHLine *)value;
- (void)addLines:(NSSet *)values;
- (void)removeLines:(NSSet *)values;

@end
