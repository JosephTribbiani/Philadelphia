//
//  PHTrain.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/26/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHLine;

@interface PHTrain : NSManagedObject

@property (nonatomic, retain) NSNumber * direction;
@property (nonatomic, retain) NSData * schedule;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) PHLine *line;

@end
