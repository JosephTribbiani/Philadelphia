//
//  PHAppDelegate.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/13/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHCoreDataManager.h"

@interface PHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow* window;
@property (strong, nonatomic) PHCoreDataManager* coreDataManger;

@end
