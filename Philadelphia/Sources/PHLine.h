//
//  PHLine.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/18/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PHLine : NSManagedObject

@property (nonatomic, retain) NSString * lineId;
@property (nonatomic, retain) NSData * shapes;

@end
