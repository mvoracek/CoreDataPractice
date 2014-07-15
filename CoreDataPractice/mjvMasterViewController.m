//
//  mjvMasterViewController.m
//  CoreDataPractice
//
//  Created by Matthew Voracek on 5/6/14.
//  Copyright (c) 2014 VOKAL. All rights reserved.
//

#import "mjvMasterViewController.h"
#import "MJVMoreInfoViewController.h"
#import "AlbumDataSource.h"
#import "Album.h"
#import "VOKCoreDataManager.h"

@interface mjvMasterViewController () <VOKFetchedResultsDataSourceDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) AlbumDataSource *dataSource;
@property (strong, nonatomic) NSArray *filteredList;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;
@property (weak, nonatomic) IBOutlet UISearchBar *albumSearchBar;
@property (strong, nonatomic) VOKCoreDataManager *managedObjectContext;

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
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"year" ascending:YES],
                                 [NSSortDescriptor sortDescriptorWithKey:@"artist" ascending:YES]];
    
    self.dataSource = [[AlbumDataSource alloc] initWithPredicate:nil
                                                       cacheName:nil
                                                       tableView:self.tableView
                                              sectionNameKeyPath:nil
                                                 sortDescriptors:sortDescriptors
                                              managedObjectClass:[Album class]];
    self.dataSource.delegate = self;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    NSIndexPath *senderIndexPath =  [self.tableView indexPathForCell:sender];
    Album *selectedAlbum = [self.dataSource.fetchedResultsController objectAtIndexPath:senderIndexPath];
    
    [segue.destinationViewController setAlbum:selectedAlbum];
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
    NSArray *albums = [[VOKCoreDataManager sharedInstance] arrayForClass:[Album class]];
    
    NSLog(@"%d", [albums count]);
    
    for (Album *album in albums) {
        if (!album.albumCover) {
            [self downloadAndDisplayAlbumCoverFromAlbum:album];
        }
    }
    
    //check for existing photo data
    //if no photo, download and save to core data
    
    
    /*[VOKCoreDataManager writeToTemporaryContext:^(NSManagedObjectContext *tempContext) {
        
    } completion:^{
        
    }];*/
    
}

#pragma mark - Session for Images

-(void)downloadAndDisplayAlbumCoverFromAlbum:(Album *)album
{
    NSString *searchValue = [album.title stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *firstPart = @"http://ws.audioscrobbler.com/2.0/?method=album.search&album=";
    NSString *secondPart = @"&api_key=445fcdcaf6a5856b90442f6a9a217bea&format=json";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",firstPart,searchValue,secondPart]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:nil];
        NSArray *images;
        NSArray *largeFilePathArray = dictionary[@"results"][@"albummatches"][@"album"];
        
        if ([largeFilePathArray isKindOfClass:[NSDictionary class]]) {
            NSDictionary *album = (NSDictionary *)largeFilePathArray;
            images = album[@"image"];
        } else {
            images = largeFilePathArray[0][@"image"];
        }
        NSLog(@"%@", dictionary);
        
        for (NSDictionary * imageDictionary in images)
        {
            if ([imageDictionary[@"size"] isEqualToString:@"large"])
            {
                NSLog(@"%@", imageDictionary[@"#text"]);
                NSString *albumLocation = imageDictionary[@"#text"];
                NSURL *albumURL = [NSURL URLWithString:albumLocation];
                
                NSURLSessionDataTask *dataTask = [session dataTaskWithURL:albumURL
                                                        completionHandler:^(NSData *data, NSURLResponse *response,
                                                                            NSError *error) {
                                                            if (!error) {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    album.albumCover = data;
                                                                    [[VOKCoreDataManager sharedInstance] saveMainContext];
                                                                });
                                                            } else {
                                                                // HANDLE ERROR //
                                                            }
                                                        }];
                [dataTask resume];
                
            }
        }
        
    }] resume];
}


@end
