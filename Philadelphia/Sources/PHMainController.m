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
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"stopId = 90502"];
    stationRequest.predicate = predicate;
    PHStation* startStation = [[self.coreDataManager.managedObjectContext executeFetchRequest:stationRequest error:NULL] lastObject];
    NSSet* startlines = startStation.lines;
    
    stationRequest.predicate = [NSPredicate predicateWithFormat:@"stopId = 90703"];
    PHStation* endStation = [[self.coreDataManager.managedObjectContext executeFetchRequest:stationRequest error:NULL] lastObject];
    NSSet* endLines = endStation.lines;
    

    if ([startlines intersectsSet:endLines])
    {
        // ont the same line
        NSLog(@"Same");
    }
    else
    {
        for (PHLine* startLine in startStation.lines)
        {
            [self bla:startLine station:endStation];
        }
        
//        NSFetchRequest* lineRequest = [NSFetchRequest fetchRequestWithEntityName:@"PHLine"];
//        lineRequest.predicate = [NSPredicate predicateWithFormat:@"lineId = 'TRE'"];
//        PHLine* line1 = [[self.coreDataManager.managedObjectContext executeFetchRequest:lineRequest error:NULL] lastObject];
//        lineRequest.predicate = [NSPredicate predicateWithFormat:@"lineId = 'NOR'"];
//        PHLine* line2 = [[self.coreDataManager.managedObjectContext executeFetchRequest:lineRequest error:NULL] lastObject];
//        NSArray* intersections = [self line:line1 intersectsLine:line2];
    }

    
    
}

- (NSArray*)line:(PHLine*)line1 intersectsLine:(PHLine*)line2
{
    NSMutableArray* mutableResult = [NSMutableArray new];
    NSArray* line1Crosses = [NSJSONSerialization JSONObjectWithData:line1.crosses options:0 error:NULL];
    for (NSDictionary* cross in line1Crosses)
    {
        for (NSString* crossLineId in [[cross allValues] lastObject])
        {
            if ([crossLineId isEqualToString:line2.lineId])
            {
                NSLog(@"got intersection");
                [mutableResult addObject:[[cross allKeys] lastObject]];
            }
        }
    }
    return [mutableResult count] == 0 ? nil : [NSArray arrayWithArray:mutableResult];
}

- (void)bla:(PHLine*)line station:(PHStation*)station
{
    NSSet* stations = line.stations;
    if ([stations containsObject:station])
    {
        NSLog(@"done");
    }
    else
    {
        NSArray* lineCrosses = [NSJSONSerialization JSONObjectWithData:line.crosses options:0 error:NULL];
        for (NSDictionary* cross in lineCrosses)
        {
            for (NSString* crossLineId in [[cross allValues] lastObject])
            {
                NSLog(@"%@",[[cross allKeys] lastObject]);
                NSFetchRequest* lineRequest = [NSFetchRequest fetchRequestWithEntityName:@"PHLine"];
                lineRequest.predicate = [NSPredicate predicateWithFormat:@"lineId = %@",crossLineId];
                PHLine* newLine = [[self.coreDataManager.managedObjectContext executeFetchRequest:lineRequest error:NULL] lastObject];
                [self bla:newLine station:station];
            }
        }
    }
}

@end
