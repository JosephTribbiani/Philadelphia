//
//  PHPosition.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/13/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PHPosition : NSManagedObject

@property (nonatomic, retain) NSNumber * direction;
@property (nonatomic, retain) NSString * unknownAttribute;
@property (nonatomic, retain) NSManagedObject *line;
@property (nonatomic, retain) NSManagedObject *station;

@end
