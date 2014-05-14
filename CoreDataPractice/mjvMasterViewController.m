//
//  mjvMasterViewController.m
//  CoreDataPractice
//
//  Created by Matthew Voracek on 5/6/14.
//  Copyright (c) 2014 VOKAL. All rights reserved.
//

#import "AlbumDataSource.h"
#import "mjvMasterViewController.h"
#import "Album.h"
#import "VOKCoreDataManager.h"

@interface mjvMasterViewController ()

@property (strong, nonatomic) AlbumDataSource *dataSource;

@end

@implementation mjvMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCustomMapper];
    [self setupDataSource];
    [self loadFromPList];
    
}

- (void)setupCustomMapper
{
    [[VOKCoreDataManager sharedInstance] setResource:nil database:@"CoreDataPractice.sqlite"];
    [[VOKCoreDataManager sharedInstance] managedObjectContext];
    
    NSArray *maps = @[MAP_FOREIGN_TO_LOCAL(@"artist", artist),
                      MAP_FOREIGN_TO_LOCAL(@"title", title),
                      MAP_FOREIGN_TO_LOCAL(@"year", year)];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:CDSELECTOR(title) andMaps:maps];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[Album class]];
}

- (void)setupDataSource
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"artist" ascending:YES],
                                 [NSSortDescriptor sortDescriptorWithKey:@"year" ascending:YES]];
    
    self.dataSource = [[AlbumDataSource alloc] initWithPredicate:nil
                                                       cacheName:nil
                                                       tableView:self.tableView
                                              sectionNameKeyPath:nil
                                                 sortDescriptors:sortDescriptors
                                              managedObjectClass:[Album class]];
}

-(void)loadFromPList
{
    NSArray *albums = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Albums" ofType:@"plist"]];
    [Album addWithArray:albums forManagedObjectContext:nil];
    [[VOKCoreDataManager sharedInstance] saveMainContext];
    
    [self loadPhotosAsynchronously];
}

- (void)loadPhotosAsynchronously
{
    //fetch all albums
    //check for existing photo data
    //if no photo, download and save to core data
    
}

@end
