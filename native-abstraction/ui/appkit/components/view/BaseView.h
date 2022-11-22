#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <vector>
#include <functional>
#include "../../../shared/KeyHandlerDefinitions.h"
#include "../../../shared/MouseHandlerDefinitions.h"

// @interface ViewLayouter : NSObject
// - (void)layout:(NSView*)view;
// @end

@interface BaseView : NSView
{
//    ViewLayouter * layouter;
@public
  std::vector<std::function<void(rehax::ui::KeyEvent&)>> keyHandlers;
  std::vector<std::function<void(rehax::ui::MouseEvent&)>> mouseHandlers;
}

- (BOOL)isFlipped;
// - (void)setLayouter:(ViewLayouter *)layouter;
@end

void AppKitNativeViewRemoveAllConstraintsWidthId(NSView * view, NSString * identifier);
