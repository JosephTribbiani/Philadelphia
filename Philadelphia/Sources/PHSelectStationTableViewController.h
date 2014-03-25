//
//  PHSelectStationTableViewController.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/25/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    PHStationTypeStart,
    PHStationTypeStop
} PHStationType;


@class PHLine;
@class PHStation;
@class PHSelectStationTableViewController;

@protocol PHSelectStationTableViewControllerDelegate <NSObject>

- (void)tableView:(PHSelectStationTableViewController*)tableView startStationDidSelect:(PHStation*)station;
- (void)tableView:(PHSelectStationTableViewController*)tableView stopStationDidSelect:(PHStation*)station;

@end

@interface PHSelectStationTableViewController : UITableViewController

@property (nonatomic, strong) PHLine* line;
@property (nonatomic, assign) PHStationType stationType;
@property (nonatomic, weak) id<PHSelectStationTableViewControllerDelegate> delegate;

@end
