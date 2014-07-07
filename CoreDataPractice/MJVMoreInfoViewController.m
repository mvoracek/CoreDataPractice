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
    
    [self downloadAlbumReview:self.album.title completionHandler:^(NSString *review) {}];
}

-(void)downloadAlbumReview: (NSString *)title completionHandler: (void (^)(NSString *))handler
{
    NSString *searchValue = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *firstPart = @"http://api.rovicorp.com/data/v1.1/album/primaryreview?album=";
    NSString *secondPart = @"&country=US&language=en&format=json&apikey=93v2rk2vdsrnzyxwv3bqvjbj&sig=7f3fbdee80bf369ec419b204792922f6";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",firstPart,searchValue,secondPart]];
    NSLog(@"%@", url);
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:nil];
        NSString *reviewText = @"(123)TV on the Radio[/roviLink]'s [roviLink=]Young Liars[/roviLink] EP was a wonderful surprise, signaling the arrival of one of the most unique acts to seemingly come out of nowhere during the 2000s. Its alchemy of strange sonic bedfellows like [roviLink=]post-punk[/roviLink] and [roviLink=]doo wop[/roviLink], and powerful vocals and [roviLink=]experimental[/roviLink] leanings, into songs that were challenging and accessible was no small feat; indeed, [roviLink=]Young Liars[/roviLink] was such an accomplished EP that it begged the question -- and ratcheted up the expectations -- of what [roviLink=]TV on the Radio[/roviLink] could do over the course of an entire album. The answer arrives with [roviLink=]Desperate Youth, Blood Thirsty Babes[/roviLink], a deeper, darker, denser version of the band's already ambitious sound. [roviLink=MN0000724928]Dave Sitek[/roviLink] and [roviLink=MN]Tunde Adepimbe[/roviLink] push their abilities as sculptors of sounds and words to new limits. [roviLink=MN]Adepimbe[/roviLink] in particular continues to prove himself as a distinctive and captivating voice, both musically and lyrically. [roviLink=MW0000332344]Desperate Youth, Blood Thirsty Babes[/roviLink]' opening track, [roviLink=]The Wrong Way,[/roviLink] is one of the best reflections of his strengths as a singer and writer, and of [roviLink=MN0000012972]TV on the Radio[/roviLink]'s overall growth. Through the song, [roviLink=]Adepimbe[/roviLink] explores his feelings about being a black man and about black culture at large. Inwardly, he wavers between radical and placating thoughts and his feelings of obligation to be Teachin' folks the score/About patience, understanding, agape babe/And sweet sweet amour. Around him, he sees mindless materialism, with bling fallin' down just like rain, and misplaced anger and violence: Hey, desperate youth! Oh bloodthirsty babes! Oh your guns are pointed the wrong way. On their own, the lyrics are strong enough to make a fairly impressive poem, but [roviLink=]Adepimbe[/roviLink]'s massed, choir-like vocals and the flutes, throbbing fuzz bass, and martial beat that [roviLink=]Sitek[/roviLink] surrounds them with turn them into an even more impressive and impassioned song. - Heather Phares";
        //NSMutableString *fixedText =
//        NSString *reviewText = dictionary[@"primaryReview"][@"text"];
        NSRange range = NSMakeRange(0, [reviewText length]);
//        NSString *fixedText = [reviewText stringByReplacingOccurrencesOfString:@"\[(.*?)]"
//                                              withString:@""
//                                                 options:NSRegularExpressionSearch
//                                                   range:range];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([aeiou])" options:0 error:&error];
        NSString *fixedText = [regex stringByReplacingMatchesInString:reviewText options:0 range:range withTemplate:@""];
        NSLog(@"%@", fixedText);
        dispatch_async(dispatch_get_main_queue(), ^{
//            if(handler)
//            {
//                handler(reviewText);
//                do {
//                    NSRange openSquare = [reviewText rangeOfString:@"["];
//                    NSRange closeSquare = [reviewText rangeOfString:@"]"];
//                    NSRange squareRange = NSMakeRange(openSquare.location, (closeSquare.location - openSquare.location + 1));
//                    NSString *fixedText = [reviewText stringByReplacingCharactersInRange:squareRange withString:@""];
//                    NSLog(@"%@", fixedText);
//                } while (reviewText != nil);
//            }
            self.reviewTextView.text = fixedText;
        });
        
        /*
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
        */
    }] resume];
}


@end
