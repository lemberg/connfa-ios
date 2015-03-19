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

#import "DCSpeakersDetailViewController.h"
#import "NSDate+DC.h"

#import "DCSpeaker+DC.h"
#import "DCEvent+DC.h"
#import "DCTimeRange+DC.h"
#import "DCTrack+DC.h"
#import "DCLevel+DC.h"

#import "DCDescriptionTextCell.h"
#import "DCSpeakerHeaderCell.h"
#import "DCSpeakerEventCell.h"
#import "DCSpeakerDetailButtonsCell.h"

#import "UIWebView+DC.h"
#import "UIConstants.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extension.h"
#import "DCEventDetailViewController.h"

static NSString *headerCellId = @"SpeakerDetailHeaderCellId";
static NSString *buttonsCellId = @"SpeakerDetailButtonsCellId";
static NSString *descriptionCellId = @"SpeakerDetailDescriptionCellId";
static NSString *eventCellId = @"SpeakerEventCellId";



@interface DCSpeakersDetailViewController ()<UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView * speakerTable;
@property (nonatomic, weak) IBOutlet UIImageView * backgroundView;
@property (nonatomic, weak) IBOutlet UIView * navBarBackgroundView;
@property (nonatomic, weak) IBOutlet UILabel * navBarBackgroundTitleLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *backgroundViewHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *backgroundViewTop;

@property (nonatomic, strong) NSIndexPath *descriptionCellIndexPath;
@property (nonatomic, strong) NSMutableDictionary *cellsHeight;

@property (nonatomic, strong) NSDictionary* cellPrototypes;

@end


@implementation DCSpeakersDetailViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.cellsHeight = [NSMutableDictionary dictionary];
    
    self.cellPrototypes = @{eventCellId : [self.speakerTable dequeueReusableCellWithIdentifier:eventCellId],
                            headerCellId : [self.speakerTable dequeueReusableCellWithIdentifier:headerCellId]};
}

- (void) arrangeNavigationBar
{
    [super arrangeNavigationBar];
    
    [self.navigationController.navigationBar setBackgroundImage: [UIImage imageWithColor:[UIColor clearColor]]
                                                  forBarMetrics: UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    self.navBarBackgroundView.alpha = 0;
    self.navBarBackgroundTitleLabel.text = self.speaker.name;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.closeCallback)
    {
        self.closeCallback();
    }
}

#pragma mark - Private

- (DCEvent*) eventForIndexPath:(NSIndexPath*)indexPath
{
    return [self.speaker.events allObjects][indexPath.row - 3];
}

- (BOOL) isFirstEvent:(NSIndexPath*)indexPath
{
    return (indexPath.row == 3);
}

#pragma mark - UITableView Delegate/DataSourse methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.speaker.events.count + 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0: // header cell
        {
            DCSpeakerHeaderCell * cellPrototype = self.cellPrototypes[headerCellId];
            [cellPrototype initData:self.speaker];
            [cellPrototype layoutSubviews];
            
            CGFloat height = [cellPrototype.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            
            [self.cellsHeight setObject:[NSNumber numberWithFloat:height] forKey:headerCellId];
            self.backgroundViewHeight.constant = height;
            
            return height;
        }
        case 1: //buttons cell
        {
            DCSpeakerDetailButtonsCell* cellPrototype = [tableView dequeueReusableCellWithIdentifier:buttonsCellId];
            [cellPrototype initData:self.speaker];
            return cellPrototype.frame.size.height;
        }
        case 2: // description cell
        {
            if (self.speaker.characteristic.length)
            {
                if (self.descriptionCellIndexPath && [self.cellsHeight objectForKey:self.descriptionCellIndexPath])
                {
                        // saved accurate value, estimated after data loading to WebView
                    return [[self.cellsHeight objectForKey:self.descriptionCellIndexPath] floatValue];
                }
                else
                {
                        // inaccurate value, used to set cell height before WebView has loaded data, will be replaced after load
                    return [DCDescriptionTextCell cellHeightForText: self.speaker.characteristic];
                }
            }
            else
            {
                return 0;
            }
        }
        default: // speaker event cell
        {
            DCSpeakerEventCell* cellPrototype = self.cellPrototypes[eventCellId];
            [cellPrototype initData: [self eventForIndexPath:indexPath]];
            [cellPrototype layoutSubviews];
            
            return [cellPrototype.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.row)
    {
        case 0: // header cell
        {
            cell = [tableView dequeueReusableCellWithIdentifier:headerCellId];
            [(DCSpeakerHeaderCell*)cell initData:self.speaker];
            break;
        }
        case 1: // cell with Share buttons (Web and Twitter)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:buttonsCellId];
            [(DCSpeakerDetailButtonsCell*)cell initData:self.speaker];
            break;
        }
        case 2: // description cell
        {
            cell = [tableView dequeueReusableCellWithIdentifier:descriptionCellId];
            [(DCDescriptionTextCell*)cell descriptionWebView].delegate = self;
            self.descriptionCellIndexPath = indexPath;
            [[(DCDescriptionTextCell*)cell descriptionWebView] loadHTMLString: self.speaker.characteristic];
            break;
        }
        default: // speaker's event cell
        {
            DCEvent * event = [self eventForIndexPath:indexPath];
            cell = [tableView dequeueReusableCellWithIdentifier:eventCellId];
            [(DCSpeakerEventCell*)cell initData: event];
            
            if (!self.speaker.characteristic.length && [self isFirstEvent: indexPath])
                [(DCSpeakerEventCell*)cell separator].hidden = YES;
            
            break;
        }
    }

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= 3)
    {
        DCEvent *event = [self eventForIndexPath:indexPath];
        
        DCEventDetailViewController * detailController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
        [detailController setEvent:event];
        [self.navigationController pushViewController:detailController animated:YES];
    }
}

#pragma mark - User actions

- (IBAction) buttonWebDidClick:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_speaker.webSite]];
}

- (IBAction) buttonTwitterDidClick:(id)sender
{
    NSString *twitter = [NSString stringWithFormat:@"http://twitter.com/%@", _speaker.twitterName];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitter]];
}

#pragma mark - UIScrollView delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.speakerTable)
    {
        float showNavBarPoint = [[self.cellsHeight objectForKey:headerCellId] floatValue];
        float offset = scrollView.contentOffset.y;
        

        if (offset < 0)
        {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0) animated:NO];
        }
        else
        {
            self.backgroundViewTop.constant = -offset/2;

            float delta = 50;
            float maxAlpha = 0.8;
            float alpha;
            
            if ((offset <= showNavBarPoint) && (offset >= showNavBarPoint-delta))
            {
                alpha = (1 - (showNavBarPoint - offset)/delta) * maxAlpha;
            }
            else
            {
                alpha = (offset >= showNavBarPoint) ? maxAlpha : 0;
            }
            self.navBarBackgroundView.alpha = alpha;
        }
    }

}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (![self.cellsHeight objectForKey:self.descriptionCellIndexPath]) {
        float height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"] floatValue];
        [self.cellsHeight setObject:[NSNumber numberWithFloat:height] forKey:self.descriptionCellIndexPath];
        
        [self.speakerTable beginUpdates];
        [self.speakerTable reloadRowsAtIndexPaths:@[self.descriptionCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.speakerTable endUpdates];
    }
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    if ( inType == UIWebViewNavigationTypeLinkClicked )
    {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

@end
