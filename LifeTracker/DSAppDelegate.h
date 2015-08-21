//
//  DSAppDelegate.h
//  LifeTracker
//
//  Created by Daniel Salowe on 4/6/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSActivity.h"
#import "Activity.h"

@interface DSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//core data
- (BOOL)addActivityFromWrapper:(DSActivity *)activity;
- (BOOL)addActivity:(Activity *)activity;
- (BOOL)checkIfAlreadyRegistered:(DSActivity*)activity;
- (NSArray *)allActivities;
- (BOOL)deleteActivityFromWrapper:(DSActivity *)activity;
- (BOOL)deleteActivity:(Activity *)activity;

@end
