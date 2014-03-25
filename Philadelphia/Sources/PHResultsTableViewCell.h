//
//  PHResultsTableViewCell.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/25/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHResultsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *trainIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *departureTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrivalTimeLabel;

@end
