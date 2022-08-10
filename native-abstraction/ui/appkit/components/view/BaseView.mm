#import "BaseView.h"

@implementation BaseView

// - (void)setLayouter:(ViewLayouter *)layouter_
// {
//   layouter = layouter_;
// }

- (BOOL)isFlipped {
  return YES;
}

// - (void)layout
// {
//   [super layout];
//   if (layouter != nil) {
//     [layouter layout:self];
//   }
// }

@end

@implementation ViewLayouter
- (void)layout:(NSView*)view
{}
@end

void AppKitNativeViewRemoveAllConstraintsWidthId(NSView * view, NSString * identifier)
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
  NSArray *filteredArray = [[view constraints] filteredArrayUsingPredicate:predicate];

  for (id constraint in filteredArray)
  {
    [view removeConstraint:constraint];
  }

//   filteredArray = [[[view superview] constraints] filteredArrayUsingPredicate:predicate];
//   for (id constraint in filteredArray)
//   {
//     if ([constraint secondItem] == view)
//     {
//       // [[view superview] removeConstraint:constraint];
//     }
//   }
}
