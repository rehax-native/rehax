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

-(void)keyDown:(NSEvent *)event {
  if (keyHandlers.size() > 0) {
    rehax::ui::KeyEvent keyEvent {
      .propagates = true,
      .isKeyDown = true,
      .key = [[event charactersIgnoringModifiers] cStringUsingEncoding:NSUTF8StringEncoding],
    };
    bool propagates = true;
    for (auto handler : keyHandlers) {
      handler(keyEvent);
      if (!keyEvent.propagates) {
        propagates = false;
      }
    }

    if (propagates) {
      [super keyDown:event];
    }
  } else {
    [super keyDown:event];
  }
}

-(void)keyUp:(NSEvent *)event {
  if (keyHandlers.size() > 0) {
    rehax::ui::KeyEvent keyEvent {
      .propagates = true,
      .isKeyDown = false,
      .key = [[event charactersIgnoringModifiers] cStringUsingEncoding:NSUTF8StringEncoding],
    };
    bool propagates = true;
    for (auto handler : keyHandlers) {
      handler(keyEvent);
      if (!keyEvent.propagates) {
        propagates = false;
      }
    }
    if (propagates) {
      [super keyUp:event];
    }
  } else {
    [super keyUp:event];
  }
}

- (void)mouseDown:(NSEvent *)theEvent {
  if (mouseHandlers.size() > 0) {
    NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    rehax::ui::MouseEvent mouseEvent {
      .isDown = true,
      .x = (float) curPoint.x,
      .y = (float) curPoint.y,
  //     .button = (int) theEvent.buttonNumber,
      .propagates = true,
    };
    bool propagates = true;
    for (auto handler : mouseHandlers) {
      handler(mouseEvent);
      if (!mouseEvent.propagates) {
        propagates = false;
      }
    }
    if (propagates) {
      [super mouseDown:theEvent];
    }
  } else {
    [super mouseDown:theEvent];
  }
}

- (void)rightMouseDown:(NSEvent *)theEvent {
  // @autoreleasepool {
  //   NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  //   mouseCallback({
  //     .left = (float) curPoint.x,
  //     .top = (float) curPoint.y,
  //     .button = (int) theEvent.buttonNumber,
  //     .isDown = true,
  //   });
  // }
}

- (void)mouseDragged:(NSEvent *)theEvent {
  if (mouseHandlers.size() > 0) {
    NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    rehax::ui::MouseEvent mouseEvent {
      .isDown = true,
      .isMove = true,
      .x = (float) curPoint.x,
      .y = (float) curPoint.y,
  //     .button = (int) theEvent.buttonNumber,
      .propagates = true,
    };
    bool propagates = true;
    for (auto handler : mouseHandlers) {
      handler(mouseEvent);
      if (!mouseEvent.propagates) {
        propagates = false;
      }
    }
    if (propagates) {
      [super mouseDragged:theEvent];
    }
  } else {
    [super mouseDragged:theEvent];
  }
}

- (void)mouseMoved:(NSEvent *)theEvent {
  if (mouseHandlers.size() > 0) {
    NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    rehax::ui::MouseEvent mouseEvent {
      .isMove = true,
      .x = (float) curPoint.x,
      .y = (float) curPoint.y,
  //     .button = (int) theEvent.buttonNumber,
      .propagates = true,
    };
    bool propagates = true;
    for (auto handler : mouseHandlers) {
      handler(mouseEvent);
      if (!mouseEvent.propagates) {
        propagates = false;
      }
    }
    if (propagates) {
      [super mouseMoved:theEvent];
    }
  } else {
    [super mouseMoved:theEvent];
  }
}
 
- (void)mouseUp:(NSEvent *)theEvent {
  if (mouseHandlers.size() > 0) {
    NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    rehax::ui::MouseEvent mouseEvent {
      .isUp = true,
      .x = (float) curPoint.x,
      .y = (float) curPoint.y,
  //     .button = (int) theEvent.buttonNumber,
      .propagates = true,
    };
    bool propagates = true;
    for (auto handler : mouseHandlers) {
      handler(mouseEvent);
      if (!mouseEvent.propagates) {
        propagates = false;
      }
    }
    if (propagates) {
      [super mouseUp:theEvent];
    }
  } else {
    [super mouseUp:theEvent];
  }
}

- (void)rightMouseUp:(NSEvent *)theEvent {
  // @autoreleasepool {
  //   NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  //   mouseCallback({
  //     .left = (float) curPoint.x,
  //     .top = (float) curPoint.y,
  //     .button = (int) theEvent.buttonNumber,
  //     .isUp = true,
  //   });
  // }
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
