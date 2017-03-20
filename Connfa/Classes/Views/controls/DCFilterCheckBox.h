
#import <UIKit/UIKit.h>

@protocol DCFilterCheckboxDelegateProtocol;

@interface DCFilterCheckBox : UIImageView {
  BOOL _selected;
}

@property(nonatomic, getter=isSelected) BOOL selected;
@property(nonatomic, weak) id<DCFilterCheckboxDelegateProtocol> delegate;

@end

@protocol DCFilterCheckboxDelegateProtocol<NSObject>

- (void)DCFilterCheckBox:(DCFilterCheckBox*)checkBox
         didChangedState:(BOOL)isSelected;

@end
