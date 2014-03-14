//
//  PHPosition.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/14/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHLine, PHStation;

@interface PHPosition : NSManagedObject

@property (nonatomic, retain) NSNumber * direction;
@property (nonatomic, retain) NSString * unknownAttribute;
@property (nonatomic, retain) PHLine *line;
@property (nonatomic, retain) PHStation *station;

@end
