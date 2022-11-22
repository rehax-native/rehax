#import "BaseText.h"
#import <objc/runtime.h>

@implementation BaseText

// -(void)keyDown:(NSEvent *)event {
// }

// -(void)keyUp:(NSEvent *)event {
// }

- (void)mouseDown:(NSEvent *)theEvent {
  // NSTextView doesn't propagate the event if isSelectable = false
  // We call the NSTextView's super method to bypass it
  Method method = class_getInstanceMethod([[self superclass] superclass], @selector(mouseDown:));
  IMP imp = method_getImplementation(method);
  
  typedef void (*fn)(id, SEL, NSEvent*);
  fn f = (fn)imp;
  f(self, @selector(mouseDown:), theEvent);
}

// - (void)rightMouseDown:(NSEvent *)theEvent {
// }

// - (void)mouseDragged:(NSEvent *)theEvent {
// }

// - (void)mouseMoved:(NSEvent *)theEvent {
// }
 
// - (void)mouseUp:(NSEvent *)theEvent {
// }

// - (void)rightMouseUp:(NSEvent *)theEvent {
// }

@end
