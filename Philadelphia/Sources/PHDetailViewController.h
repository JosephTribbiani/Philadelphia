//
//  PHViewController.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/13/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHLine;
@class PHStation;

@interface PHDetailViewController : UIViewController

- (void)selectLine:(PHLine*)line;
- (void)showCalloutViewForStation:(PHStation*)station;

@end
