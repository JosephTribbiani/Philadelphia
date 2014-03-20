//
//  PHViewController.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/13/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//
#import <MapKit/MapKit.h>

#import "PHMainController.h"
#import "PHCoreDataManager.h"
#import "PHAppDelegate.h"
#import "PHLine.h"
#import "PHStation.h"
#import "PHAnnotation.h"

@interface PHMainController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@property (nonatomic, strong) PHCoreDataManager* coreDataManager;

@end

@implementation PHMainController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.coreDataManager = ((PHAppDelegate*)[UIApplication sharedApplication].delegate).coreDataManger;
    
    [self addLimes];
    [self addAnnotations];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    
    [self calculations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addAnnotations
{
    NSFetchRequest* request = [NSFetchRequest new];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"PHStation" inManagedObjectContext:self.coreDataManager.managedObjectContext];
    request.entity = entityDescription;
    
    NSArray* stations = [self.coreDataManager.managedObjectContext executeFetchRequest:request error:NULL];
    
    for (PHStation* station in stations)
    {
        PHAnnotation* annotation = [[PHAnnotation alloc] initWithLatitude:[station.latitude floatValue] longitude:[station.longitude floatValue] title:station.name subtitle:station.stopId];
        [self.mapView addAnnotation:annotation];
    }
}

- (void)addLimes
{
    NSFetchRequest* request = [NSFetchRequest new];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"PHLine" inManagedObjectContext:self.coreDataManager.managedObjectContext];
    request.entity = entityDescription;
    
    NSArray* lines = [self.coreDataManager.managedObjectContext executeFetchRequest:request error:NULL];
    for (PHLine* line in lines)
    {
        NSArray* shapes = [NSJSONSerialization JSONObjectWithData:line.shapes options:0 error:NULL];
        for (NSArray* shape in shapes)
        {
            NSUInteger i = 0;
            CLLocationCoordinate2D coordinates[[shape count]];
            for (NSArray* point in shape)
            {
                coordinates[i++] = CLLocationCoordinate2DMake([point[0] floatValue], [point[1] floatValue]);
            }
            MKPolyline* polyLine = [MKPolyline polylineWithCoordinates:coordinates count:[shape count]];
            [self.mapView addOverlay:polyLine];
        }
    }
}

#pragma mark - MapViewDelegate

- (MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayRenderer* result = nil;
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor redColor];
        renderer.alpha = 0.5;
        renderer.lineWidth = 5.0;
        result = renderer;
    }
    return result;
}

#pragma mark - Calculations

- (void)calculations
{
    NSFetchRequest* request = [NSFetchRequest new];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"PHLine" inManagedObjectContext:self.coreDataManager.managedObjectContext];
    request.entity = entityDescription;
    
    NSArray* lines = [self.coreDataManager.managedObjectContext executeFetchRequest:request error:NULL];
    for (PHLine* line in lines)
    {
//        NSLog(@"---------------------");
//        NSLog(@"line: %@",line.lineId);
//        NSLog(@"crosses: %@",[NSJSONSerialization JSONObjectWithData:line.crosses options:0 error:NULL ]);
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    NSFetchRequest* stationRequest = [NSFetchRequest fetchRequestWithEntityName:@"PHStation"];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"stopId = 90208"];
    stationRequest.predicate = predicate;
    PHStation* startStation = [[self.coreDataManager.managedObjectContext executeFetchRequest:stationRequest error:NULL] lastObject];
    NSSet* startlines = startStation.lines;
    NSSet* trains = startStation.trains;
    
    
    stationRequest.predicate = [NSPredicate predicateWithFormat:@"stopId = 90208"];
    PHStation* endStation = [[self.coreDataManager.managedObjectContext executeFetchRequest:stationRequest error:NULL] lastObject];
    NSSet* endLines = endStation.lines;
    NSMutableSet* endStationIds = [NSMutableSet new];
    for (PHLine* line in endLines)
    {
        [endStationIds addObject:line.lineId];
    }

    
    NSMutableSet* pathes = [NSMutableSet new];
    
    if ([startlines intersectsSet:endLines])
    {
        // ont the same line
        NSLog(@"Same");
    }
    else
    {
        for (PHLine* line in startStation.lines)
        {
            NSArray* crossLines = [NSJSONSerialization JSONObjectWithData:line.crosses options:0 error:NULL];
            for (NSDictionary* cross in crossLines)
            {
                NSSet* crossLinesIds = [NSSet setWithArray:[[cross allValues] lastObject]];
                if ([crossLinesIds intersectsSet:endStationIds])
                {
                    [pathes addObject:[[cross allKeys] lastObject]];
                }
            }
        }
        NSLog(@"pathes: %@",pathes);
    }
}

@end
