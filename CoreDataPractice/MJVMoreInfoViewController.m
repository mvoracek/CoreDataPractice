//
//  MJVMoreInfoViewController.m
//  CoreDataPractice
//
//  Created by Matthew Voracek on 5/15/14.
//  Copyright (c) 2014 VOKAL. All rights reserved.
//

#import "MJVMoreInfoViewController.h"
#import "Album.h"

@interface MJVMoreInfoViewController ()

@property (strong, atomic) Album *album;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumCoverImage;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;

@end

@implementation MJVMoreInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

- (void)setAlbum:(Album *)album
{
    _album = album;
    [self configureView];
}

- (void)configureView
{
    self.artistLabel.text = self.album.artist;
    self.titleLabel.text = self.album.title;
    self.yearLabel.text = [self.album.year stringValue];
    self.albumCoverImage.image = [UIImage imageWithData:self.album.albumCover];
    
    [self downloadAlbumReview:self.album.title completionHandler:^(NSDictionary *review) {}];
}

-(void)downloadAlbumReview: (NSString *)title completionHandler: (void (^)(NSDictionary *))handler
{
    NSString *searchValue = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *firstPart = @"http://api.rovicorp.com/data/v1.1/album/primaryreview?album=";
    NSString *secondPart = @"&country=US&language=en&format=json&apikey=93v2rk2vdsrnzyxwv3bqvjbj&sig=7abed9e51d8db8ab55033f1cdc8f9812";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",firstPart,searchValue,secondPart]];
    NSLog(@"%@", url);
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:nil];
        NSString *reviewText = dictionary[@"primaryReview"][@"text"];
        NSString *updatedText = [reviewText stringByReplacingOccurrencesOfString:@"[" withString:@"~"];
        NSRange range = NSMakeRange(0, [reviewText length]);
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"~(.*?)]" options:0 error:&error];
        NSString *fixedText = [regex stringByReplacingMatchesInString:updatedText options:0 range:range withTemplate:@""];
        NSLog(@"%@", fixedText);
        dispatch_async(dispatch_get_main_queue(), ^{
            if(handler)
            {
                handler(dictionary);
            }
            self.reviewTextView.text = fixedText;
        });
    }] resume];
}


@end
