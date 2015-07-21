//
//  POI.h
//  BlocSpot
//
//  Created by Stephen Blair on 7/17/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface POI : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * yCoordinate;
@property (nonatomic, retain) NSNumber * xCoordinate;

@end
