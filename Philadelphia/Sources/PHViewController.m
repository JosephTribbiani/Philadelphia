//
//  PHViewController.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/13/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHViewController.h"
#import "PHNetworkingManager.h"

@interface PHViewController ()

@end

@implementation PHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PHNetworkingManager* manager = [PHNetworkingManager new];
    NSDictionary* result = [manager getJSON];
    NSLog(@"%@",result);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
