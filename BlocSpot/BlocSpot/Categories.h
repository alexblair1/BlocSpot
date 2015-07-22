//
//  Categories.h
//  BlocSpot
//
//  Created by Stephen Blair on 7/21/15.
//  Copyright (c) 2015 blairgraphix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Categories : NSManagedObject

@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * red;
@property (nonatomic, retain) NSNumber * blue;
@property (nonatomic, retain) NSNumber * green;

@end
