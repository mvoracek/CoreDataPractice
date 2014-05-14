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
    
    [self downloadAndDisplayAlbumCoverFromTitle:album.title atIndexPath:indexPath];
    
    [cell layoutWithAlbum:album];
    
    return cell;
}

-(void)downloadAndDisplayAlbumCoverFromTitle:(NSString *)title atIndexPath:(NSIndexPath *)indexPath
{
    NSString *searchValue = [title stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *firstPart = @"http://ws.audioscrobbler.com/2.0/?method=album.search&album=";
    NSString *secondPart = @"&api_key=445fcdcaf6a5856b90442f6a9a217bea&format=json";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",firstPart,searchValue,secondPart]];
    
    [self beginSession:url forIndexPath:indexPath];
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

-(void)beginSession: (NSURL *)url forIndexPath: (NSIndexPath *)indexPath
{
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
        
        [self downloadImages:images usingSession:session forIndexPath:indexPath];
        
    }] resume];
}

-(void)downloadImages: (NSArray *)images usingSession: (NSURLSession *)session forIndexPath: (NSIndexPath *)indexPath
{
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
                                                                 UIImage *image = [UIImage imageWithData:data];
                                                                 mjvMasterTableViewCell *cell = (mjvMasterTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                                                                 [cell setAlbumCover:image];
                                                             });
                                                         } else {
                                                             // HANDLE ERROR //
                                                         }
                                                     }];
            [dataTask resume];
            
//            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:albumURL]];
//            UIImage *image = [UIImage imageWithData:data];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                mjvMasterTableViewCell *cell = (mjvMasterTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//                [cell setAlbumCover:image];
//            });
        }
    }
}

@end
