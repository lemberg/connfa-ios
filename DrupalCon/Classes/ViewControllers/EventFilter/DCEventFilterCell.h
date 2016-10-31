
#import <UIKit/UIKit.h>
#import "DCFilterCheckBox.h"

#define FilterCellTypeCount 2

typedef enum {
  FilterCellTypeLevel = 0,
  FilterCellTypeTrack,
} FilterCellType;

@interface DCEventFilterCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel* title;
@property(nonatomic, weak) IBOutlet DCFilterCheckBox* checkBox;
@property(nonatomic, weak) IBOutlet UIView* separator;

@property(nonatomic) FilterCellType type;
@property(nonatomic, weak) NSNumber* relatedObjectId;

@end
