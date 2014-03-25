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

#import "PHDetailViewController.h"
#import "PHCoreDataManager.h"
#import "PHAppDelegate.h"
#import "PHLine.h"
#import "PHStation+Utils.h"
#import "PHAnnotation.h"
#import "PHTrain.h"

#define kNumberOfTrainsToAccept 10

@interface PHDetailViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@property (nonatomic, strong) PHCoreDataManager* coreDataManager;
@property (nonatomic, strong) NSMutableDictionary* lines;

@property (strong, nonatomic) PHLine* selectedLine;

@end

@implementation PHDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.coreDataManager = ((PHAppDelegate*)[UIApplication sharedApplication].delegate).coreDataManger;
    
    [self addLines];
//    [self addAnnotations];
//    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(39.95, -75.166667), MKCoordinateSpanMake(1, 1)) animated:YES];
    
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
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"PHStation"];
    request.predicate = [NSPredicate predicateWithFormat:@"ANY lines.lineId == %@",self.selectedLine.lineId];
    NSArray* stations = [self.coreDataManager.managedObjectContext executeFetchRequest:request error:NULL];
    
    for (PHStation* station in stations)
    {
        PHAnnotation* annotation = [[PHAnnotation alloc] initWithLatitude:[station.latitude floatValue] longitude:[station.longitude floatValue] title:station.name subtitle:station.stopId];
        annotation.stopId = station.stopId;
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
            objc_setAssociatedObject(polyLine, "lineId", line.lineId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            if ([line.lineId isEqualToString:self.selectedLine.lineId])
            {
                [self.mapView insertOverlay:polyLine atIndex:NSIntegerMax];
            }
            else
            {
                [self.mapView insertOverlay:polyLine atIndex:0];
            }
        }
        lineIndex++;
    }
}

- (void)showCalloutViewForStation:(PHStation*)station
{
    NSArray* annotations = [self.mapView annotations];
    for (id<MKAnnotation> annotation in annotations)
    {
        if ([annotation isKindOfClass:[PHAnnotation class]])
        {
            if ([((PHAnnotation*)annotation).stopId isEqualToString:station.stopId])
            {
                
                [self.mapView selectAnnotation:annotation animated:YES];
            }
        }
    }
    
}

//- (void)highlightStationsFromStation:(PHStation*)station1 toStation:(PHStation*)station2 onLine:(PHLine*)line
//{
//    [self.mapView removeAnnotations:[self.mapView annotations]];
//    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"PHStation"];
//    request.predicate = [NSPredicate predicateWithFormat:@"ANY lines.lineId == %@",self.selectedLine.lineId];
//    NSArray* stations = [self.coreDataManager.managedObjectContext executeFetchRequest:request error:NULL];
//    
//    NSInteger station1Position = [station1 positionForLine:line direction:1];
//    NSInteger station2Position = [station2 positionForLine:line direction:1];
//    
//    NSInteger maxPosition = station1Position > station2Position ? station1Position : station2Position;
//    NSInteger minPosition = station1Position < station2Position ? station1Position : station2Position;
//    
//    for (PHStation* station in stations)
//    {
//    
//        if ([station positionForLine:line direction:1] <= maxPosition && [station positionForLine:line direction:1] >= minPosition)
//        {
//            PHAnnotation* annotation = [[PHAnnotation alloc] initWithLatitude:[station.latitude floatValue] longitude:[station.longitude floatValue] title:station.name subtitle:station.stopId];
//            annotation.pinColor = MKPinAnnotationColorGreen;
//            [self.mapView addAnnotation:annotation];
//        }
//        else
//        {
//            PHAnnotation* annotation = [[PHAnnotation alloc] initWithLatitude:[station.latitude floatValue] longitude:[station.longitude floatValue] title:station.name subtitle:station.stopId];
//            annotation.pinColor = MKPinAnnotationColorRed;
//            [self.mapView addAnnotation:annotation];
//        }
//        PHAnnotation* annotation = [[PHAnnotation alloc] initWithLatitude:[station.latitude floatValue] longitude:[station.longitude floatValue] title:station.name subtitle:station.stopId];
//        [self.mapView addAnnotation:annotation];
//    }
//}

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

#pragma mark -

- (void)selectLine:(PHLine*)line
{
    self.selectedLine = line;
    [self.mapView removeOverlays:[self.mapView overlays]];
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self addLines];
    [self addAnnotations];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

#pragma mark - MapViewDelegate

- (MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayRenderer* result = nil;
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        if ([self.selectedLine.lineId isEqualToString:objc_getAssociatedObject(overlay, "lineId")])
        {
            renderer.strokeColor = [UIColor redColor];
            renderer.alpha = 1;
        }
        else
        {
            renderer.strokeColor = [UIColor blueColor];
            renderer.alpha = 0.5;
        }
        renderer.lineWidth = 5.0;
        result = renderer;
    }
    return result;
}

//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
//{
//    NSString* stopId = [view.annotation subtitle];
//    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"PHStation"];
//    request.predicate = [NSPredicate predicateWithFormat:@"stopId = %@",stopId];
//    PHStation* station = [[self.coreDataManager.managedObjectContext executeFetchRequest:request error:NULL] lastObject];
//    
////    NSSet* trains = station.trains;
////    NSLog(@"station: %@ TRAINS ---------------------------------------------", station.stopId);
////    for(PHTrain* train in trains)
////    {
////        NSLog(@"%@",train.signature);
////    }
//    
//    NSLog(@"station: %@ LINES ---------------------------------------------", station.stopId);
//    NSSet* lines = station.lines;
//    for(PHLine* line in lines)
//    {
//        NSLog(@"%@",line.lineId);
//    }
//    
//    NSDictionary* positions = [NSJSONSerialization JSONObjectWithData:station.positions options:0 error:NULL];
//}

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//{
//    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
//    
//    if (pin == nil)
//    {
//        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: @"pin"];
//    }
//    else
//    {
//        pin.annotation = annotation;
//    }
////    pin.pinColor = ((PHAnnotation*)annotation).pinColor;
//    
//    return pin;
//}

#pragma mark - Calculations

- (NSArray*)findTrainsFromStation:(PHStation*)startStation toStation:(PHStation*)stopStation
{
    NSMutableArray* result = [NSMutableArray new];

    NSSet* startStationTrains = startStation.trains;
    NSSet* stopStationTrains = stopStation.trains;
    
    NSMutableSet* crossTrains = [startStationTrains mutableCopy];
    [crossTrains intersectSet:stopStationTrains];
    
    for (PHTrain* train in crossTrains)
    {
        if ([self directionForLine:train.line startStation:startStation stopStation:stopStation] == [train.direction boolValue])
        {
            NSArray* schedules = [NSJSONSerialization JSONObjectWithData:train.schedule options:0 error:NULL];
            for (NSDictionary* schedule in schedules)
            {
                NSString* days = schedule[@"days"];
                NSRange dayRange = [days rangeOfString:[self currentDayOfWeek]];
                if (dayRange.location != NSNotFound)
                {
                    NSArray* startTimes = [schedule[@"schedule"] objectForKey:startStation.stopId];
                    NSArray* endTimes = [schedule[@"schedule"] objectForKey:stopStation.stopId];
                    NSTimeInterval currentTime = [self currentTimeIntervalSinceMidnight];
                    NSUInteger index = 0;
                    for (NSNumber* time in startTimes)
                    {
                        if ([time floatValue] > currentTime)
                        {
                            [result addObject:@{@"trainId" : train.signature,
                                                       @"startTime" : time,
                                                       @"endTime" : [endTimes objectAtIndex:index]}];
                        }
                        index++;
                        NSLog(@"%@", [time stringValue]);
                    }
                }
            }
        }
    }
    
    [result sortUsingComparator:^NSComparisonResult(NSDictionary* time1, NSDictionary* time2)
     {
         return [[time1 objectForKey:@"startTime"] compare:[time2 objectForKey:@"startTime"]];
     }];
    
    return [result count] == 0 ? nil : [NSArray arrayWithArray:result];
}

- (void)calculations
{
    NSFetchRequest* startRequest = [NSFetchRequest fetchRequestWithEntityName:@"PHStation"];
    startRequest.predicate = [NSPredicate predicateWithFormat:@"stopId = 1285"];
    PHStation* startStation = [[self.coreDataManager.managedObjectContext executeFetchRequest:startRequest error:NULL] lastObject];
    
    NSFetchRequest* stopRequest = [NSFetchRequest fetchRequestWithEntityName:@"PHStation"];
    stopRequest.predicate = [NSPredicate predicateWithFormat:@"stopId = 1281"];
    PHStation* stopStation = [[self.coreDataManager.managedObjectContext executeFetchRequest:stopRequest error:NULL] lastObject];
    
    NSArray* possibleResults = [self findTrainsFromStation:startStation toStation:stopStation];
    for (NSDictionary* possibleResult in possibleResults)
    {
         NSLog(@"train: %@ time: %@ endTime: %@", possibleResult[@"trainId"], [self stringFromTimeInterval:[possibleResult[@"startTime"] integerValue]],[self stringFromTimeInterval:[possibleResult[@"endTime"] integerValue]]);
    }
}

- (BOOL)directionForLine:(PHLine*) line startStation:(PHStation*)startStation stopStation:(PHStation*)stopStation
{
    NSDictionary* startStationPositions = [[NSJSONSerialization JSONObjectWithData:startStation.positions options:0 error:NULL] objectForKey:line.lineId];
    NSInteger startStationDirectPosition = [[startStationPositions objectForKey:@"0"] integerValue];
    
    NSDictionary* stopStationPositions = [[NSJSONSerialization JSONObjectWithData:stopStation.positions options:0 error:NULL] objectForKey:line.lineId];
    NSInteger stopStationDirectPosition = [[stopStationPositions objectForKey:@"0"] integerValue];
    
    if (startStationDirectPosition < stopStationDirectPosition)
    {
        return NO;
    }
    else
    {
        return YES;
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

- (NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval
{
    NSInteger integerTimeInterval = (NSInteger)timeInterval;
    NSInteger seconds = integerTimeInterval % 60;
    NSInteger minutes = (integerTimeInterval / 60) % 60;
    NSInteger hours = (integerTimeInterval / 3600);
    return [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
}

@end
