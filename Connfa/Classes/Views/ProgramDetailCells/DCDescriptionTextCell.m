
#import "DCDescriptionTextCell.h"

@implementation DCDescriptionTextCell

+ (float)cellHeightForText:(NSString*)text {
  UITextView* textView = [self DC_textViewWithText:text];
  CGSize sizeThatShouldFitTheContent =
      [textView sizeThatFits:textView.frame.size];
  return sizeThatShouldFitTheContent.height;
}

+ (UITextView*)DC_textViewWithText:(NSString*)text {
  UITextView* textView =
      [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
  [textView setFont:[UIFont systemFontOfSize:10]];
  [textView setTextColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1]];
  [textView setText:text];

  return textView;
}

@end
