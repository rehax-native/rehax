#include "Gesture.h"
#import <Cocoa/Cocoa.h>

@interface RehaxGestureRecognizer : NSGestureRecognizer
{
    @public

    std::function<void(void)> callback;
    std::function<void(float, float)> onMouseDownCb;
    std::function<void(float, float)> onMouseUpCb;
    std::function<void(float, float)> onMouseMoveCb;
}

- (void) performAction;

@end

@implementation RehaxGestureRecognizer

- (void) mouseDown:(NSEvent *) event
{
    NSPoint event_location = event.locationInWindow;
    NSPoint local_point = [self.view convertPoint:event_location fromView:nil];

    onMouseDownCb(local_point.x, local_point. y);
}

- (void) mouseUp:(NSEvent *) event
{
    NSPoint event_location = event.locationInWindow;
    NSPoint local_point = [self.view convertPoint:event_location fromView:nil];

    onMouseUpCb(local_point.x, local_point. y);
}

- (void) mouseDragged:(NSEvent *) event
{
    NSPoint event_location = event.locationInWindow;
    NSPoint local_point = [self.view convertPoint:event_location fromView:nil];

    onMouseMoveCb(local_point.x, local_point. y);
}

- (void) performAction
{
    @autoreleasepool {
        callback();
    }
}

@end

void rehax::Gesture::setup(std::function<void(void)> action, std::function<void(float, float)> onMouseDown, std::function<void(float, float)> onMouseUp, std::function<void(float, float)> onMouseMove)
{
    RehaxGestureRecognizer * rec = [RehaxGestureRecognizer new];

    rec->callback = action;
    rec->onMouseDownCb = onMouseDown;
    rec->onMouseUpCb = onMouseUp;
    rec->onMouseMoveCb = onMouseMove;

    [rec setTarget:rec];
    [rec setAction:@selector(performAction)];

    native = (void *) CFBridgingRetain(rec);
}

void rehax::Gesture::destroy()
{
    CFBridgingRelease(native);
}

void rehax::Gesture::setState(rehax::GestureState state)
{
    NSGestureRecognizer * rec = (__bridge NSGestureRecognizer *) native;

    switch (state) {
        case GestureState_Possible:
            rec.state = NSGestureRecognizerStatePossible;
            break;
        case GestureState_Recognized:
            rec.state = NSGestureRecognizerStateRecognized;
            break;
        case GestureState_Began:
            rec.state = NSGestureRecognizerStateBegan;
            break;
        case GestureState_Changed:
            rec.state = NSGestureRecognizerStateChanged;
            break;
        case GestureState_Cancelled:
            rec.state = NSGestureRecognizerStateCancelled;
            break;
        case GestureState_Ended:
            rec.state = NSGestureRecognizerStateEnded;
            break;
    }
}
