//
//  MJVMoreInfoViewController.m
//  CoreDataPractice
//
//  Created by Matthew Voracek on 5/15/14.
//  Copyright (c) 2014 VOKAL. All rights reserved.
//

#import "MJVMoreInfoViewController.h"
#import "Album.h"
#import <CommonCrypto/CommonCrypto.h>

@interface MJVMoreInfoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, atomic) Album *album;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumCoverImage;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *moreInfoControl;
@property (weak, nonatomic) IBOutlet UITableView *trackTableView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property (strong, nonatomic) NSArray *tracks;

@end

static NSString *Api = @"93v2rk2vdsrnzyxwv3bqvjbj";
static NSString *ApiPlusSecret = @"93v2rk2vdsrnzyxwv3bqvjbjkGPDNCJDSx";

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
    [self.trackTableView setDelegate:self];
    [self.trackTableView setDataSource:self];
    
    self.artistLabel.text = self.album.artist;
    self.titleLabel.text = self.album.title;
    self.yearLabel.text = [self.album.year stringValue];
    self.albumCoverImage.image = [UIImage imageWithData:self.album.albumCover];
    
    NSURL *tracksUrl = [self createURLWithTitle:self.album.title parameter:@"tracks"];
    NSURL *reviewUrl = [self createURLWithTitle:self.album.title parameter:@"primaryreview"];
    self.spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake(160, 350);
    self.spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    [self downloadAlbumTracks:tracksUrl completionHandler:^(NSDictionary *tracks) {}];
    [self downloadAlbumReview:reviewUrl completionHandler:^(NSDictionary *review) {}];
}

- (IBAction)moreInfoViewSwitch:(id)sender {
    self.moreInfoControl = (UISegmentedControl *)sender;
    NSInteger selection = self.moreInfoControl.selectedSegmentIndex;
    
    if (selection == 1) {
        //review
        [self.reviewTextView setHidden:NO];
        [self.trackTableView setHidden:YES];
    } else {
        //tracks
        [self.reviewTextView setHidden:YES];
        [self.trackTableView setHidden:NO];
    }
}

- (NSString *) md5
{
    NSDate *aDate = [NSDate date];
    NSString *timestamp = [NSString stringWithFormat:@"%.0f", [aDate timeIntervalSince1970]];
    NSString *concatenatedAuthString = [ApiPlusSecret stringByAppendingString:timestamp];
    const char *cStr = [concatenatedAuthString UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

- (NSURL *) createURLWithTitle: (NSString *)title parameter: (NSString *)parameter
{
    NSString *newSig = [self md5];
    NSString *searchValue = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *firstPart = @"http://api.rovicorp.com/data/v1.1/album/";
    NSString *album = @"?album=";
    NSString *secondPart = @"&country=US&language=en&format=json&apikey=93v2rk2vdsrnzyxwv3bqvjbj&sig=";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@",firstPart,parameter,album, searchValue,secondPart,newSig]];
    NSLog(@"%@", url);
    return url;
}

- (void)downloadAlbumReview: (NSURL *)url completionHandler: (void (^)(NSDictionary *))handler
{
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

- (void)downloadAlbumTracks: (NSURL *)url completionHandler: (void (^)(NSDictionary *))handler
{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:nil];
        
        self.tracks = [dictionary objectForKey:@"tracks"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            [self.trackTableView reloadData];
            if(handler)
            {
                handler(dictionary);
            }
        });
    }] resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tracks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"TracksID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    NSDictionary *tempDictionary = [self.tracks objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [tempDictionary objectForKey:@"title"];
    
    return cell;
}

@end
