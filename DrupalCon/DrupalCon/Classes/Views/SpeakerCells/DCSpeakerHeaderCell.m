//
//  The MIT License (MIT)
//  Copyright (c) 2014 Lemberg Solutions Limited
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "DCSpeakerHeaderCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+DC.h"
#import "DCSpeaker.h"

@implementation DCSpeakerHeaderCell

- (void)awakeFromNib
{
    [self.photoImageView cutCircle];
}

- (void) initData:(DCSpeaker *)speaker
{
        // Photo image
    [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:speaker.avatarPath]
                          placeholderImage: [UIImage imageNamed:@"avatar_placeholder"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [self setNeedsDisplay];
                                     });
                                     
                                 }];
    
        // Name text
    self.nameLabel.text = speaker.name;
    
        // Job and Company text
    NSMutableString *jobAndCompany = speaker.jobTitle.length ? [speaker.jobTitle mutableCopy] : @"";
    if (speaker.organizationName.length)
        [jobAndCompany appendString:[NSString stringWithFormat:@" at %@", speaker.organizationName]];
    self.jobAndCompanyLabel.text = jobAndCompany;
}

@end
