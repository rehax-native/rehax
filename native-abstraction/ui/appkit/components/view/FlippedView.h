#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface FlippedView : NSView
- (BOOL)isFlipped;
@end

void AppKitNativeViewRemoveAllConstraintsWidthId(NSView * view, NSString * identifier);