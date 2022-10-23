#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <functional>

@interface FunctionalNSPopUpButton : NSPopUpButton
{
  @public
    std::function<void(void)> callback;
}

- (void)setCallback:(std::function<void(void)>)callback;
- (void)handleSelection:(NSMenuItem*)item;

@end
