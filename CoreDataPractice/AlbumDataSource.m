//
//  AlbumDataSource.m
//  CoreDataPractice
//
//  Created by Matthew Voracek on 5/6/14.
//  Copyright (c) 2014 VOKAL. All rights reserved.
//

#import "AlbumDataSource.h"
#import "Album.h"
#import "mjvMasterTableViewCell.h"

static NSString *const CoolCellIdentifier = @"Cell";

@implementation AlbumDataSource

-(UITableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath
{
    Album *album = [_fetchedResultsController objectAtIndexPath:indexPath];
    mjvMasterTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CoolCellIdentifier];
    
    if (!cell) {
        //is this necessary with storyboards? will there ever not be a cell ready?
        cell = [[mjvMasterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:CoolCellIdentifier];
    }
    
    NSString * albumCoverURL = [self createJSONForAlbumCover:album.title];
    
    [cell layoutWithAlbum:album withAlbumCoverURL:albumCoverURL];
    
    return cell;
}

-(NSString *)createJSONForAlbumCover: (NSString *)str
{
    __block NSString *albumURL = nil;
    NSString *searchValue = [str stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *firstPart = @"http://ws.audioscrobbler.com/2.0/?method=album.search&album=";
    NSString *secondPart = @"&api_key=445fcdcaf6a5856b90442f6a9a217bea&format=json";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",firstPart,searchValue,secondPart]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:nil];
        //NSLog(@"%@", dictionary[@"results"]);
        NSArray *images;
        NSArray *largeFilePathArray = dictionary[@"results"][@"albummatches"][@"album"];
        if ([largeFilePathArray isKindOfClass:[NSDictionary class]]) {
            NSDictionary *album = (NSDictionary *)largeFilePathArray;
            images = album[@"image"];
        } else {
            images = largeFilePathArray[0][@"image"];
        }
        
        for (NSDictionary * imageDictionary in images)
        {
            if ([imageDictionary[@"size"] isEqualToString:@"large"])
            {
                NSLog(@"%@", imageDictionary[@"#text"]);
                albumURL = imageDictionary[@"#text"];
            }
        }
    }] resume];
    
    return albumURL;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[tableView indexPathForSelectedRow] isEqual: indexPath] )
        return 170.0;
    else
        return 50.0;
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [UIView setAnimationsEnabled:NO];
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [UIView setAnimationsEnabled:YES];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
