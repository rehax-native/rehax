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

- (BOOL)acceptsFirstResponder {
  return YES;
}

-(void)keyDown:(NSEvent *)event
{
  rehax::ui::KeyEvent keyEvent {
    .isKeyDown = true,
    .key = [[event charactersIgnoringModifiers] cStringUsingEncoding:NSUTF8StringEncoding],
  };
  for (auto handler : keyHandlers) {
    handler(keyEvent);
  }
}

-(void)keyUp:(NSEvent *)event
{
  rehax::ui::KeyEvent keyEvent {
    .isKeyDown = false,
    .key = [[event charactersIgnoringModifiers] cStringUsingEncoding:NSUTF8StringEncoding],
  };
  for (auto handler : keyHandlers) {
    handler(keyEvent);
  }
}

@end

// @implementation ViewLayouter
// - (void)layout:(NSView*)view
// {}
// @end

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
