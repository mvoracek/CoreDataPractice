//
//  mjvMasterTableViewCell.m
//  CoreDataPractice
//
//  Created by Matthew Voracek on 5/6/14.
//  Copyright (c) 2014 VOKAL. All rights reserved.
//

#import "mjvMasterTableViewCell.h"
#import "Album.h"

@interface mjvMasterTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumImage;
@end

@implementation mjvMasterTableViewCell

- (void)layoutWithAlbum:(Album *)album withAlbumCoverURL: (NSString *) albumCoverURL
{
    NSLog(@"%@", albumCoverURL);
    //[self createJSONForAlbumCover:album.title];
    
    self.artistLabel.text = album.artist;
    self.titleLabel.text = album.title;
    self.yearLabel.text = album.year.description;
    self.albumImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:albumCoverURL]]];
}

@end
