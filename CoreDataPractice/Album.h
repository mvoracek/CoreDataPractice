//
//  Album.h
//  CoreDataPractice
//
//  Created by Matthew Voracek on 5/7/14.
//  Copyright (c) 2014 VOKAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Album : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * year;

@property (nonatomic, retain) NSData *albumCover;

@end
