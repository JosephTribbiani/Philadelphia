//
//  PHModelManager.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/14/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol PHCoreDatamanagerDelegate <NSObject>

- (void)trainMapDidLoad;

@end

@interface PHCoreDataManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@property (nonatomic, weak) id<PHCoreDatamanagerDelegate> delegate;

- (void)saveContext;
- (void)loadTrainMap;

@end
