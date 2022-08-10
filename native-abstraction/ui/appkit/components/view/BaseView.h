#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

// @interface ViewLayouter : NSObject
// - (void)layout:(NSView*)view;
// @end

@interface BaseView : NSView
{
//    ViewLayouter * layouter;
}

- (BOOL)isFlipped;
// - (void)setLayouter:(ViewLayouter *)layouter;
@end

void AppKitNativeViewRemoveAllConstraintsWidthId(NSView * view, NSString * identifier);
