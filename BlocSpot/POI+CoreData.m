//
//  POI+CoreData.m
//  BlocSpot
//
//  Created by Stephen Blair on 7/28/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import "POI+CoreData.h"

@implementation POI (CoreData)


+ (NSArray *)fetchItemsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    NSArray *results = [[NSArray alloc] init];
    
    
    //prepare fetch request for items
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    request.entity = [NSEntityDescription entityForName:@"POI" inManagedObjectContext:managedObjectContext];
    
    
    //execute fetch request
    NSError *error = nil;
    
    NSArray *items = [managedObjectContext executeFetchRequest:request error:&error];
    
    if(items) {
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];
        
        results = [items sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    return results;
}

+ (NSArray *)fetchDistinctItemGroupsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    NSArray *results = [[NSArray alloc] init];
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"POI" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    
    [request setResultType:NSDictionaryResultType];
    
    [request setReturnsDistinctResults:YES];
    
    [request setPropertiesToFetch:@[@"subtitle"]];
    
    NSError *error = nil;
    
    //note, an array of NSDictionaries is returned where the key is the property name (e.g. group) and the value is the letter
    NSArray *items = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:items.count];
    
    for(NSDictionary *currentDictionary in items) {
        
        [mutableArray addObject:[currentDictionary objectForKey:@"subtitle"]];
    }
    
    results = [NSArray arrayWithArray:mutableArray];
    
    return results;
}

+ (NSArray *)fetchItemNamesBeginningWith:(NSString *)searchText inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    NSArray *results = [[NSArray alloc] init];
    
    //prepare fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    request.entity = [NSEntityDescription entityForName:@"POI" inManagedObjectContext:managedObjectContext];
    
    request.predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[c] %@", searchText];
    
    //execute fetch request
    NSArray *items =  [managedObjectContext executeFetchRequest:request error:nil];
    
    //serialize to an array of name string objects
    NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:items.count];
    
    for(POI *currentItem in items) {
        //add the item name
        [names addObject:currentItem];
    }
    
    NSLog(@"names array: %@", names);
    
    //serialize to non-mutable
    results = [NSArray arrayWithArray: names];
    
    return results;
}

+ (NSArray *)fetchItemNamesByGroupInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    NSArray *results = [[NSArray alloc] init];
    
    
    //groups
    NSArray *itemGroups = [POI fetchDistinctItemGroupsInManagedObjectContext:managedObjectContext];
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:itemGroups.count];
    
    for(NSString *group in itemGroups) {
        
        //items in group
        NSArray *groupItems = [POI fetchItemNamesBeginningWith:group inManagedObjectContext:managedObjectContext];
        
        
        //create item and group structure
        NSDictionary *itemAndGroup = [[NSDictionary alloc] initWithObjectsAndKeys:groupItems, group, nil];
        
        [mutableArray addObject:itemAndGroup];
    }
    
    //serialize to non-mutable
    results = [NSArray arrayWithArray:mutableArray];
    
    return results;
}

+ (NSDictionary *)fetchItemNamesByGroupFilteredBySearchText:(NSString *)searchText inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    NSDictionary *result = nil;
    
    //to be used as the key for the returned NSDictionary
    NSString *firstLetterOfSearchText = [[searchText substringToIndex:1] uppercaseString];
    
    NSArray *itemNames = [POI fetchItemNamesBeginningWith:searchText inManagedObjectContext:managedObjectContext];
    
    result = [[NSDictionary alloc] initWithObjectsAndKeys:itemNames, firstLetterOfSearchText, nil];
    
    return result;
}

@end
