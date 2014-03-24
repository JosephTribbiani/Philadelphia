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

#import "PHDetailViewController.h"

@interface PHMasterViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) PHCoreDataManager* coreDataManager;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *startStationButton;
@property (weak, nonatomic) IBOutlet UIButton *stopStationButton;

@property (strong, nonatomic) NSArray* lines;

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

@end
