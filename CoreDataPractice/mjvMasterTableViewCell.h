//
//  mjvMasterTableViewCell.h
//  CoreDataPractice
//
//  Created by Matthew Voracek on 5/6/14.
//  Copyright (c) 2014 VOKAL. All rights reserved.
//

@class Album;

@interface mjvMasterTableViewCell : UITableViewCell

- (void)layoutWithAlbum:(Album *)album withAlbumCoverURL: (NSString *) albumCoverURL;

@end
