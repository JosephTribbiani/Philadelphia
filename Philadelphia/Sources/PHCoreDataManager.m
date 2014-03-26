//
//  PHModelManager.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/14/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHCoreDataManager.h"
#import "PHNetworkingManager.h"
#import "PHLine+Create.h"
#import "PHStation+Utils.h"
#import "PHTrain+Create.h"

@interface PHCoreDataManager()

@property (nonatomic, strong) PHNetworkingManager* networkingManager;

@end

@implementation PHCoreDataManager

- (void)saveContext
{
    NSError* error = nil;
    NSManagedObjectContext* managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel*)managedObjectModel
{
    if (_managedObjectModel == nil)
    {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL* storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DataStore.sqlite"];
    
    NSError* error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark -

- (PHNetworkingManager *)networkingManager
{
    if (_networkingManager == nil)
    {
        _networkingManager = [PHNetworkingManager new];
    }
    return _networkingManager;
}

- (void)loadTrainMap
{
    [self.networkingManager requestTransportInfoWithCompletionHandler:^(NSDictionary *transportInfo)
    {
        for (NSDictionary* line in transportInfo[@"lines"])
        {
            [PHLine lineWithInfo:line inManagedObjectContext:self.managedObjectContext];
        }
        
        for (NSDictionary* stop in transportInfo[@"stops"])
        {
            [PHStation stationWithInfo:stop inManagedObjectContext:self.managedObjectContext];
        }
        
        for (NSDictionary* train in transportInfo[@"trains"])
        {
            [PHTrain trainWithInfo:train inManagedObjectContext:self.managedObjectContext];
        }
        
        if ([self.managedObjectContext hasChanges])
        {
            [self.managedObjectContext save:NULL];
        }
        [self.delegate trainMapDidLoad];
    }];
}

@end
