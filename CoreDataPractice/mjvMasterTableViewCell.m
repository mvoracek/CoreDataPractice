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
    [self createJSONForAlbumCover:album.title];
    
    self.artistLabel.text = album.artist;
    self.titleLabel.text = album.title;
    self.yearLabel.text = album.year.description;
    self.albumImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:albumCoverURL]]];
}

-(void)createJSONForAlbumCover: (NSString *)str
{
    NSString *searchValue = [str stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    //http://ws.audioscrobbler.com/2.0/?method=album.search&album=ALBUMTITLE&api_key=445fcdcaf6a5856b90442f6a9a217bea&format=json
    NSString *firstPart = @"http://ws.audioscrobbler.com/2.0/?method=album.search&album=";
    NSString *secondPart = @"&api_key=445fcdcaf6a5856b90442f6a9a217bea&format=json";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",firstPart,searchValue,secondPart]];
    //NSLog(@"%@", url);
    //NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:nil];
        NSLog(@"%@", dictionary[@"results"]);
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
            }
        }
    }] resume];
}

@end
