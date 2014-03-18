//
//  PHViewController.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/13/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHMainController.h"
#import <MapKit/MapKit.h>

@interface PHMainController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView* mapView;

@end

@implementation PHMainController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
