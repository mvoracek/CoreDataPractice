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
    
    [cell layoutWithAlbum:album];
    
    
    
    return cell;
}

#pragma mark - Table View Methods


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


@end
