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

@interface PHDetailViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView* mapView;

@property (nonatomic, strong) PHCoreDataManager* coreDataManager;
@property (strong, nonatomic) PHLine* selectedLine;
@property (nonatomic, strong) NSArray* polylines;

@end

@implementation PHDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.coreDataManager = ((PHAppDelegate*)[UIApplication sharedApplication].delegate).coreDataManger;
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(39.95, -75.166667), MKCoordinateSpanMake(1, 1)) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (NSArray *)polylines
{
    if (_polylines == nil)
    {
        NSMutableArray* polylines = [NSMutableArray new];
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"PHLine"];
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
                MKPolyline* polyline = [MKPolyline polylineWithCoordinates:coordinates count:[shape count]];
                objc_setAssociatedObject(polyline, "lineId", line.lineId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                [polylines addObject:polyline];
            }
        }
        _polylines = [NSArray arrayWithArray:polylines];
    }
    return _polylines;
}

- (void)addLines
{
    for (MKPolyline* polyline in self.polylines)
    {
        NSString* lineId = objc_getAssociatedObject(polyline, "lineId");
        if ([lineId isEqualToString:self.selectedLine.lineId])
        {
            [self.mapView insertOverlay:polyline atIndex:NSIntegerMax];
        }
        else
        {
            [self.mapView insertOverlay:polyline atIndex:0];
        }
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

#pragma mark -

- (void)selectLine:(PHLine*)line
{
    if (line == nil)
    {
        [self.mapView removeOverlays:[self.mapView overlays]];
        [self.mapView removeAnnotations:[self.mapView annotations]];
        [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(39.95, -75.166667), MKCoordinateSpanMake(1, 1)) animated:YES];
    }
    else
    {
        self.selectedLine = line;
        [self.mapView removeOverlays:[self.mapView overlays]];
        [self.mapView removeAnnotations:[self.mapView annotations]];
        [self addLines];
        [self addAnnotations];
        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    }
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

@end
