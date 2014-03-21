//
//  PHViewController.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/13/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//


// https://shopandride.cogniance.com/parcsr-ci/rest/transport/schedule?previousUpdateUtm=0
// http://json.parser.online.fr
// http://www.septa.org/maps/pdf/click-map.pdf

#import <MapKit/MapKit.h>
#import <objc/runtime.h>

#import "PHMainController.h"
#import "PHCoreDataManager.h"
#import "PHAppDelegate.h"
#import "PHLine.h"
#import "PHStation.h"
#import "PHAnnotation.h"
#import "PHTrain.h"

@interface PHMainController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@property (nonatomic, strong) PHCoreDataManager* coreDataManager;
@property (nonatomic, strong) NSMutableDictionary* lines;

@end

@implementation PHMainController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.coreDataManager = ((PHAppDelegate*)[UIApplication sharedApplication].delegate).coreDataManger;
    
    [self addLines];
    [self addAnnotations];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    
    [self calculations];
    self.lines = [NSMutableDictionary new];
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

- (void)addLines
{
    NSFetchRequest* request = [NSFetchRequest new];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"PHLine" inManagedObjectContext:self.coreDataManager.managedObjectContext];
    request.entity = entityDescription;
    
    NSArray* lines = [self.coreDataManager.managedObjectContext executeFetchRequest:request error:NULL];
    NSUInteger lineIndex = 0;
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
            objc_setAssociatedObject(polyLine, "color", [[self colors] objectAtIndex:lineIndex], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(polyLine, "lineId", line.lineId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [self.mapView addOverlay:polyLine];
        }
        lineIndex++;
    }
}

- (NSArray*)colors
{
    return @[[UIColor redColor],
             [UIColor blueColor],
             [UIColor greenColor],
             [UIColor grayColor],
             [UIColor brownColor],
             [UIColor blackColor],
             [UIColor yellowColor],
             [UIColor cyanColor],
             [UIColor magentaColor],
             [UIColor purpleColor],
             [UIColor orangeColor],
             [UIColor whiteColor],
             [UIColor lightGrayColor],
             [UIColor darkGrayColor],
             [UIColor redColor],
             [UIColor greenColor],
             [UIColor orangeColor]];
}

#pragma mark - MapViewDelegate

- (MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayRenderer* result = nil;
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = objc_getAssociatedObject(overlay, "color");
        renderer.alpha = 0.5;
        renderer.lineWidth = 5.0;
        result = renderer;
    }
    return result;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSString* stopId = [view.annotation subtitle];
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"PHStation"];
    request.predicate = [NSPredicate predicateWithFormat:@"stopId = %@",stopId];
    PHStation* station = [[self.coreDataManager.managedObjectContext executeFetchRequest:request error:NULL] lastObject];
    
//    NSSet* trains = station.trains;
//    NSLog(@"station: %@ TRAINS ---------------------------------------------", station.stopId);
//    for(PHTrain* train in trains)
//    {
//        NSLog(@"%@",train.signature);
//    }
    
    NSLog(@"station: %@ LINES ---------------------------------------------", station.stopId);
    NSSet* lines = station.lines;
    for(PHLine* line in lines)
    {
        NSLog(@"%@",line.lineId);
    }
    
    NSDictionary* positions = [NSJSONSerialization JSONObjectWithData:station.positions options:0 error:NULL];
}

#pragma mark - Calculations

- (void)calculations
{
    NSFetchRequest* startRequest = [NSFetchRequest fetchRequestWithEntityName:@"PHStation"];
    startRequest.predicate = [NSPredicate predicateWithFormat:@"stopId = 1281"];
    PHStation* startStation = [[self.coreDataManager.managedObjectContext executeFetchRequest:startRequest error:NULL] lastObject];

    NSFetchRequest* stopRequest = [NSFetchRequest fetchRequestWithEntityName:@"PHStation"];
    stopRequest.predicate = [NSPredicate predicateWithFormat:@"stopId = 1284"];
    PHStation* stopStation = [[self.coreDataManager.managedObjectContext executeFetchRequest:stopRequest error:NULL] lastObject];
    
    NSSet* startStationTrains = startStation.trains;
    NSSet* stopStationTrains = stopStation.trains;
    
    NSMutableSet* crossTrains = [startStationTrains mutableCopy];
    [crossTrains intersectSet:stopStationTrains];
    
    NSMutableArray* possibleTimes = [NSMutableArray new];
    
    for(PHTrain* train in crossTrains)
    {
        NSArray* schedules = [NSJSONSerialization JSONObjectWithData:train.schedule options:0 error:NULL];
        for (NSDictionary* schedule in schedules)
        {
            NSString* days = schedule[@"days"];
            NSRange dayRange = [days rangeOfString:[self currentDayOfWeek]];
            if (dayRange.location != NSNotFound)
            {
                NSLog(@"------------------");
                NSArray* startTimes = [schedule[@"schedule"] objectForKey:startStation.stopId];
                NSArray* endTimes = [schedule[@"schedule"] objectForKey:stopStation.stopId];
                NSLog(@"train: %@",train.signature);
                NSTimeInterval currentTime = 17090;//[self currentTimeIntervalSinceMidnight];
                NSUInteger index = 0;
                for (NSNumber* time in startTimes)
                {
                    if ([time floatValue] > currentTime)
                    {
                        [possibleTimes addObject:@{@"trainId" : train.signature,
                                                   @"startTime" : time,
                                                   @"endTime" : [endTimes objectAtIndex:index]}];
                    }
                    index++;
                    NSLog(@"%@", [time stringValue]);
                }
            }
        }
    }
    
    [possibleTimes sortUsingComparator:^NSComparisonResult(NSDictionary* time1, NSDictionary* time2)
    {
        return [[time1 objectForKey:@"startTime"] compare:[time2 objectForKey:@"startTime"]];
    }];
    
    
    NSLog(@"Current time: %f",[self currentTimeIntervalSinceMidnight]);
    NSUInteger index = 0;
    for (NSDictionary* possibleTime in possibleTimes)
    {
        NSLog(@"train: %@ time: %@ endTime: %@", possibleTime[@"trainId"], possibleTime[@"startTime"], possibleTime[@"endTime"]);
        if (index > 10)
        {
            break;
        }
        index++;
    }
}

- (NSString*)currentDayOfWeek
{
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%d",[components weekday] - 1];
}

- (NSTimeInterval)currentTimeIntervalSinceMidnight
{
    NSDate* currentDate = [NSDate date];
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:currentDate];
    NSDate* midnightDate = [calendar dateFromComponents:components];
    return [currentDate timeIntervalSinceDate:midnightDate];
}

@end
