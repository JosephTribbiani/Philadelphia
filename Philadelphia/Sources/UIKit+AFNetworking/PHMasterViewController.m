//
//  PHMasterViewController.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/24/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHMasterViewController.h"
#import "PHCoreDataManager.h"
#import "PHAppDelegate.h"
#import "PHLine.h"
#import "PHSelectStationTableViewController.h"
#import "PHStation.h"
#import "PHTrain.h"
#import "PHResultsTableViewCell.h"
#import "PHDetailViewController.h"

@interface PHMasterViewController () <UIPickerViewDelegate, UIPickerViewDataSource, PHSelectStationTableViewControllerDelegate, UITableViewDataSource>

@property (strong, nonatomic) PHCoreDataManager* coreDataManager;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *startStationButton;
@property (weak, nonatomic) IBOutlet UIButton *stopStationButton;
@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;

@property (strong, nonatomic) NSArray* lines;
@property (strong, nonatomic) PHLine* selectedLine;
@property (strong, nonatomic) UIPopoverController* popOverController;
@property (strong, nonatomic) PHStation* startStation;
@property (strong, nonatomic) PHStation* stopStation;
@property (strong, nonatomic) NSArray* resultsToShow;

@end

@implementation PHMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)awakeFromNib
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.pickerView reloadAllComponents];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PHCoreDataManager *)coreDataManager
{
    if (_coreDataManager == nil)
    {
        _coreDataManager = ((PHAppDelegate*)[UIApplication sharedApplication].delegate).coreDataManger;
    }
    return _coreDataManager;
}

- (NSArray *)lines
{
    if (_lines == nil)
    {
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"PHLine"];
        _lines = [self.coreDataManager.managedObjectContext executeFetchRequest:request error:NULL];
    }
    return _lines;
}

#pragma mark - Actions

- (IBAction)startStationButtonDidPressed:(id)sender
{
}

- (IBAction)stopStationButtonDidPressed:(id)sender
{
    
}

- (IBAction)searchTrain:(id)sender
{
    self.resultsToShow = [self findTrainsFromStation:self.startStation toStation:self.stopStation];
    [self.resultsTableView reloadData];
}

#pragma mark - PickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    PHLine* line = [self.lines objectAtIndex:row];
    return line.lineId;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    PHDetailViewController* detailViewController = (PHDetailViewController*)[[self.splitViewController.viewControllers objectAtIndex:1] topViewController];
    [detailViewController selectLine:[self.lines objectAtIndex:row]];
    self.selectedLine = [self.lines objectAtIndex:row];
}

#pragma mark - PickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.lines count];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.popOverController = [(UIStoryboardPopoverSegue*)segue popoverController];
    PHSelectStationTableViewController* destinationViewController = (PHSelectStationTableViewController*)segue.destinationViewController;
    destinationViewController.line = self.selectedLine;
    destinationViewController.delegate = self;
    if ([segue.identifier isEqualToString:@"selectStartStationSegue"])
    {
        destinationViewController.stationType = PHStationTypeStart;
    }
    else if ([segue.identifier isEqualToString:@"selectStopStationSegue"])
    {
        destinationViewController.stationType = PHStationTypeStop;
    }
}

#pragma mark - PHSelectStationTableViewControllerDelegate

- (void)tableView:(PHSelectStationTableViewController*)tableView startStationDidSelect:(PHStation*)station
{
    [self.popOverController dismissPopoverAnimated:YES];
    [self.startStationButton setTitle:station.name forState:UIControlStateNormal];
    self.startStation = station;
    PHDetailViewController* detailViewController = (PHDetailViewController*)[[self.splitViewController.viewControllers objectAtIndex:1] topViewController];
    [detailViewController showCalloutViewForStation:station];
}

- (void)tableView:(PHSelectStationTableViewController *)tableView stopStationDidSelect:(PHStation *)station
{
    [self.popOverController dismissPopoverAnimated:YES];
    [self.stopStationButton setTitle:station.name forState:UIControlStateNormal];
    self.stopStation = station;
    PHDetailViewController* detailViewController = (PHDetailViewController*)[[self.splitViewController.viewControllers objectAtIndex:1] topViewController];
    [detailViewController showCalloutViewForStation:station];
}

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

#pragma mark - ResultsTableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHResultsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCellIdentifier"];
    NSDictionary* train = [self.resultsToShow objectAtIndex:indexPath.row];
    cell.trainIdLabel.text = train[@"trainId"];
    cell.departureTimeLabel.text = [self stringFromTimeInterval:[train[@"startTime"] floatValue]];
    cell.arrivalTimeLabel.text = [self stringFromTimeInterval:[train[@"endTime"] floatValue]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultsToShow == nil ? 0 : [self.resultsToShow count];
}
@end
