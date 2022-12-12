#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <functional>
#include "../view/ObjcDefinitions.h"

#define FunctionalNSButton MakeClassName(FunctionalNSButton)

@interface FunctionalNSButton : NSButton
{
  @public
  std::function<void(void)> callback;
}

- (void)setOnPress:(std::function<void(void)>)callback;
- (void)onPress:(id)sender;

@end
