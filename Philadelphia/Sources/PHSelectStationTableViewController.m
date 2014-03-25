//
//  PHSelectStationTableViewController.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/25/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHSelectStationTableViewController.h"
#import "PHLine.h"
#import "PHStation+Utils.h"

@interface PHSelectStationTableViewController ()

@property (nonatomic, strong) NSArray* stations;

@end

@implementation PHSelectStationTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setLine:(PHLine *)line
{
    _line = line;
    self.stations = [[self.line.stations allObjects] sortedArrayUsingComparator:^NSComparisonResult(PHStation* station1, PHStation* station2)
    {
        return [@([station1 positionForLine:self.line direction:0]) compare:@([station2 positionForLine:self.line direction:0])];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.line stations] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell.textLabel setText:[[self.stations objectAtIndex:indexPath.row] name]];
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.stationType == PHStationTypeStart)
    {
        [self.delegate tableView:self startStationDidSelect:self.stations[indexPath.row]];
    }
    else if (self.stationType == PHStationTypeStop)
    {
        [self.delegate tableView:self stopStationDidSelect:self.stations[indexPath.row]];

    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
