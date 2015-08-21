//
//  DSAppDelegate.m
//  LifeTracker
//
//  Created by Daniel Salowe on 4/6/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import "DSAppDelegate.h"

@implementation DSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Date Implementation

- (BOOL)addActivityFromWrapper:(DSActivity *)activity
{
    if (![self checkIfAlreadyRegistered:activity]) {
        Activity *activityToStore = [NSEntityDescription insertNewObjectForEntityForName:@"Activity"
                                                                  inManagedObjectContext:self.managedObjectContext];
        activityToStore.name = activity.name;
        activityToStore.time = activity.time;
        activityToStore.date = activity.date;
        activityToStore.aboveBelow = activity.aboveBelow;
        activityToStore.startTime = activity.startTime;
        activityToStore.endTime = activity.endTime;
        activityToStore.type = activity.type;
        activityToStore.timeElasped = activity.timeElasped;
        activityToStore.completed = activity.completed;
        activityToStore.longitude = activity.longitude;
        activityToStore.latitude = activity.latitude;
        activityToStore.previousDays = activity.previousDays;
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {     //committing changes
            return NO;
        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL)addActivity:(Activity *)activity
{
    
    Activity *activityToStore = [NSEntityDescription insertNewObjectForEntityForName:@"Activity"
                                                              inManagedObjectContext:self.managedObjectContext];
    activityToStore.name = activity.name;
    activityToStore.time = activity.time;
    activityToStore.date = activity.date;
    activityToStore.aboveBelow = activity.aboveBelow;
    activityToStore.startTime = activity.startTime;
    activityToStore.endTime = activity.endTime;
    activityToStore.type = activity.type;
    activityToStore.timeElasped = activity.timeElasped;
    activityToStore.completed = activity.completed;
    activityToStore.longitude = activity.longitude;
    activityToStore.latitude = activity.latitude;
    activityToStore.previousDays = activity.previousDays;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {     //committing changes
        return NO;
    }
    
    return YES;
}


- (BOOL)checkIfAlreadyRegistered:(DSActivity *)activity
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Activity"
                                              inManagedObjectContext:self.managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == %@ AND type == %@ AND time == %@ AND aboveBelow == %@ AND date == %@ AND startTime == %@ AND endTime == %@ AND timeElasped == %@ AND completed == %@ AND latitude == %@ AND longitude == %@ AND previousDays == %@",activity.name, activity.type,activity.time, activity.aboveBelow, activity.date, activity.startTime, activity.endTime, activity.timeElasped, activity.completed, activity.latitude, activity.longitude, activity.previousDays];
    fetchRequest.entity = entity;
    
    NSError *error;
    NSArray *fetchedResults = [self.managedObjectContext
                               executeFetchRequest:fetchRequest
                               error:&error];
    
    return [fetchedResults count] > 0;
}

- (NSArray *)allActivities
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Activity"
                                              inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSError *error;
    NSArray *fetchedResults = [self.managedObjectContext
                               executeFetchRequest:fetchRequest
                               error:&error];
    
    return fetchedResults;
}


- (BOOL)deleteActivityFromWrapper:(DSActivity *)activity
{
    Activity *activityToDelete = [[Activity alloc] init];
    activityToDelete.name = activity.name;
    activityToDelete.time = activity.time;
    activityToDelete.date = activity.date;
    activityToDelete.aboveBelow = activity.aboveBelow;
    activityToDelete.startTime = activity.startTime;
    activityToDelete.endTime = activity.endTime;
    activityToDelete.type = activity.type;
    activityToDelete.timeElasped = activity.timeElasped;
    activityToDelete.completed = activity.completed;
    activityToDelete.latitude = activity.latitude;
    activityToDelete.longitude = activity.longitude;
    activityToDelete.previousDays = activity.previousDays;
    
    [self.managedObjectContext deleteObject:activityToDelete];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {     //committing changes
        return NO;
    }
    
    return YES;
}

- (BOOL)deleteActivity:(Activity *)activity
{
    Activity *activityToDelete = activity;
    activityToDelete.name = activity.name;
    activityToDelete.time = activity.time;
    activityToDelete.date = activity.date;
    activityToDelete.aboveBelow = activity.aboveBelow;
    activityToDelete.startTime = activity.startTime;
    activityToDelete.endTime = activity.endTime;
    activityToDelete.type = activity.type;
    activityToDelete.timeElasped = activity.timeElasped;
    activityToDelete.completed = activity.completed;
    activityToDelete.latitude = activity.latitude;
    activityToDelete.longitude = activity.longitude;
    activityToDelete.previousDays = activity.previousDays;
    
    [self.managedObjectContext deleteObject:activityToDelete];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {     //committing changes
        return NO;
    }
    
    return YES;
}



#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LifeTracker" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LifeTracker.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
