//
//  PHRoute.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/14/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHLine, PHSpecificRoute;

@interface PHRoute : NSManagedObject

@property (nonatomic, retain) NSNumber * direction;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) PHLine *line;
@property (nonatomic, retain) NSSet *specificRoute;
@end

@interface PHRoute (CoreDataGeneratedAccessors)

- (void)addSpecificRouteObject:(PHSpecificRoute *)value;
- (void)removeSpecificRouteObject:(PHSpecificRoute *)value;
- (void)addSpecificRoute:(NSSet *)values;
- (void)removeSpecificRoute:(NSSet *)values;

@end
