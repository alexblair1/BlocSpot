//
//  POI+CoreData.h
//  BlocSpot
//
//  Created by Stephen Blair on 7/28/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import "POI.h"

@interface POI (CoreData)


/*!
 * @description For fetching all item entities from CoreData.
 * @param managedObjectContext The CoreData NSManagedObjectContext.
 * @return NSArray of Item entity objects.
 */
+ (NSArray *)fetchItemsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/*!
 * @description For fetching a collection of distinct 'group' attributes across all instances of the Item entity
 * @param managedObjectContext The CoreData NSManagedObjectContext.
 * @return NSArray of Item entity objects.
 */
+ (NSArray *)fetchDistinctItemGroupsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/*!
 * @description For fetching a NSArray of Item names beginning with the passed in search text.
 * @param searchText The search text used to filter the returned item names.
 * @param managedObjectContext The CoreData NSManagedObjectContext.
 * @return NSArray of string objects representing item names.
 */
+ (NSArray *)fetchItemNamesBeginningWith:(NSString *)searchText inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/*!
 * @description For fetching a collection of NSDictionaries where the key is the Group and the value is a collection of Item Names.
 * @param managedObjectContext The CoreData NSManagedObjectContext.
 * @return NSArray of NSDictionaries.
 */
+ (NSArray *)fetchItemNamesByGroupInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/*!
 * @description For returning a NSDictionary where the key is the first letter of the input searchText and the value is a NSArray of items string objects that begin with the input searchText.
 * @param managedObjectContext The CoreData NSManagedObjectContext.
 * @return NSDictionary
 */
+ (NSDictionary *)fetchItemNamesByGroupFilteredBySearchText:(NSString *)searchText inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
