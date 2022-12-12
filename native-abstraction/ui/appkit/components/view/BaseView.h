#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <vector>
#include <functional>
#include "../../../shared/KeyHandlerDefinitions.h"
#include "../../../shared/MouseHandlerDefinitions.h"
#include "./ObjcDefinitions.h"

#define BaseView MakeClassName(BaseView)

@interface BaseView : NSView
{
@public
  std::vector<std::function<void(rehax::ui::KeyEvent&)>> keyHandlers;
  std::vector<std::function<void(rehax::ui::MouseEvent&)>> mouseHandlers;
}

- (BOOL)isFlipped;
@end

void AppKitNativeViewRemoveAllConstraintsWidthId(NSView * view, NSString * identifier);
